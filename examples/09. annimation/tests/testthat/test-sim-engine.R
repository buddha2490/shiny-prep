# =============================================================================
# test-sim-engine.R — unit tests for the pure random-walk physics
# =============================================================================

test_that("new_swarm seeds particles inside the box, all trapped", {
  set.seed(1)
  s <- new_swarm(50, box_w = 100, box_h = 100, margin = 5)

  expect_length(s$x, 50)
  expect_length(s$y, 50)
  expect_true(all(s$active))                       # nobody starts escaped
  expect_true(all(is.na(s$escape_step)))           # no escape times yet
  # Within the interior margin on every axis.
  expect_true(all(s$x >= 5 & s$x <= 95))
  expect_true(all(s$y >= 5 & s$y <= 95))
})

test_that("new_swarm rejects an empty swarm", {
  expect_error(new_swarm(0), "at least 1")
})

test_that("advance keeps trapped particles inside the box (reflection)", {
  set.seed(2)
  s <- new_swarm(200, box_w = 100, box_h = 100)
  # Big steps + a closed-ish door to stress the reflection logic.
  for (i in seq_len(100)) {
    res <- advance(s, step_size = 4, door_lo = 49, door_hi = 51)
    s <- res$swarm
  }
  act <- s$active
  # Every still-trapped particle must remain within the walls.
  expect_true(all(s$x[act] >= 0 & s$x[act] <= 100))
  expect_true(all(s$y[act] >= 0 & s$y[act] <= 100))
})

test_that("a particle aimed at the door escapes and is recorded", {
  # One particle sitting just inside the door; a guaranteed rightward step
  # carries it through. We force the angle by stubbing runif to return 0
  # (cos(0) = 1, so it moves +x).
  s <- list(x = 99.5, y = 50, active = TRUE, escape_step = NA_real_)
  local_mocked_bindings <- NULL
  with_mocked <- function() {
    res <- advance(s, step_size = 2, door_lo = 45, door_hi = 55)
    res
  }
  # Stub runif within this test only.
  testthat::local_mocked_bindings(
    runif = function(n, min = 0, max = 1) rep(0, n),
    .package = "stats"
  )
  res <- advance(s, step_size = 2, door_lo = 45, door_hi = 55)
  expect_equal(res$newly_escaped, 1L)
  expect_false(res$swarm$active[1])
})

test_that("a particle hitting the solid right wall reflects, not escapes", {
  s <- list(x = 99.5, y = 10, active = TRUE, escape_step = NA_real_)  # y below door
  testthat::local_mocked_bindings(
    runif = function(n, min = 0, max = 1) rep(0, n),  # step straight right
    .package = "stats"
  )
  res <- advance(s, step_size = 2, door_lo = 45, door_hi = 55)
  expect_length(res$newly_escaped, 0)
  expect_true(res$swarm$active[1])
  expect_lte(res$swarm$x[1], 100)                  # bounced back inside
})

test_that("escaped particles drift and ignore walls", {
  s <- list(x = 100, y = 50, active = FALSE, escape_step = 5)
  testthat::local_mocked_bindings(
    runif = function(n, min = 0, max = 1) rep(0, n),  # cos(0)=1 → +x
    .package = "stats"
  )
  res <- advance(s, step_size = 2, door_lo = 45, door_hi = 55)
  # Free walk (+2 from angle) plus rightward drift (0.6 * 2) — past the wall.
  expect_gt(res$swarm$x[1], 100)
})

test_that("escape_summary reports NA before any escape, stats after", {
  expect_equal(escape_summary(rep(NA_real_, 5))$n, 0L)
  expect_true(is.na(escape_summary(rep(NA_real_, 5))$mean))

  s <- escape_summary(c(NA, 10, 20, 30, NA))
  expect_equal(s$n, 3L)
  expect_equal(s$min, 10)
  expect_equal(s$max, 30)
  expect_equal(s$mean, 20)
})

test_that("a full run eventually empties the box", {
  # Pure 2D diffusion to a small exit has a heavy tail (the unluckiest particle
  # can take many thousands of steps). Use a small swarm and a wide door so the
  # run terminates well within the cap regardless of seed; the heavy-tail
  # behaviour itself is the app's headline finding, not something a test gates.
  set.seed(99)
  s <- new_swarm(15, box_w = 100, box_h = 100)
  step <- 0L
  while (any(s$active) && step < 200000L) {
    res <- advance(s, step_size = 3, door_lo = 10, door_hi = 90)
    s <- res$swarm
    step <- step + 1L
    if (length(res$newly_escaped)) {
      s$escape_step[res$newly_escaped] <- step
    }
  }
  expect_false(any(s$active))                       # everyone got out
  expect_true(all(!is.na(s$escape_step)))           # all times recorded
})

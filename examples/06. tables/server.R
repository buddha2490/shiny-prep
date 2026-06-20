# server.R --------------------------------------------------------------------
#
# Wires each tab to its module server. The datasets (ADSL/ADAE/ADLB) are built
# once in global.R and passed in as plain data frames — the modules own all the
# table logic.

server <- function(input, output, session) {

  mod_dt_table_server("dt", adae = ADAE)

  mod_reactable_table_server("reactable", adlb = ADLB)

  mod_gt_table_server("gt", adae = ADAE, adsl = ADSL)

  mod_rhandsontable_table_server("rhot", queries = make_queries(ADSL))
}

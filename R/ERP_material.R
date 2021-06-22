#' 物料属性批量修改
#'
#' @param file 文件名
#' @param sheet 页答
#' @param lang 语言
#'
#' @return 返回值
#' @export
#'
#' @examples
#' erp_materia_read()
erp_materia_read <-function(file="data-raw/VM物料批量修改模板.xlsx",sheet = "物料",lang='cn'){
  #library(readxl)
  mtrl_fp_info <- readxl::read_excel(file,
                                     sheet = sheet, col_types = c("text",
                                                                 "text", "text", "text", "text", "text",
                                                                 "text", "text", "numeric", "numeric",
                                                                 "text", "text", "text", "numeric"))
  if(lang == 'en'){
    names(mtrl_fp_info) <-c('FNewNumber','FFpName','FFpModel')
  }
  return(mtrl_fp_info)

}

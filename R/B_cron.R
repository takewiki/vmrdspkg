
#' 同步功能设置
#'
#' @param r_file  文件名
#' @param time 时间
#' @param id ID
#' @param description 描述
#'
#' @return 返回值
#' @export
#'
#' @examples
#' cron_set()
cron_set <- function(r_file,time =15,id='id1',description = 'Weather') {
  cmd <- cronR::cron_rscript(r_file)
  if(time == 60){
    frequency = 'hourly'
  }else{
    frequency = paste0("*/",time," * * * *")
  }

  flag <- cronR::cron_ls(id=id)
  if (!is.null(flag)){
    #如果已经存在，则删除后重建
    cronR::cron_rm(id)
  }

  cronR::cron_add(cmd, frequency = frequency, id = id, description = description)

}

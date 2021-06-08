# 1.0获取物料处理列表 ----
# if exists(select * from sys.objects where  name ='vw_PLMtoERP_Item')
# drop view vw_PLMtoERP_Item
# go
# create view vw_PLMtoERP_Item
# as
# select MCode,MProp,PLMBatchnum from PLMtoERP_Item
# where ERPDate is null
# go
#' 获取物料的处理清单
#'
#' @param conn 连接
#'
#' @return 返回值
#' @export
#'
#' @examples
#' Item_getList()
Item_getList <- function(conn=conn_vm_erp_test()) {

  sql <- paste0("select * from  vw_PLMtoERP_Item
order by PLMBatchnum,MProp,MCode")
  res <- tsda::sql_select(conn,sql)
  return(res)

}

# 1.1 Pre写入物料前的准备工作------

# 1.1写入一行物料数据--------
#' 写入一行物料数据
#'
#' @param conn 连接
#' @param MCode 物料编码
#' @param MProp 属性
#' @param PLMBatchnum  批次号
#'
#' @return 返回值
#' @export
#'
#' @examples
#' Item_readIntoERP_One()
Item_readIntoERP_One <- function(conn=conn_vm_erp_test(),
                                 MCode,
                                 MProp,
                                 PLMBatchnum

                                 ){
#写入代码：
#处理一行物料信息
#外购与委外都没有成本对象

#写入日志表


}

# 1.2写入所有物料数据-------
#' 将所有数据写入物料表
#'
#' @param conn 连接
#'
#' @return 返回值
#' @export
#'
#' @examples
#' Item_readIntoERP_ALL()
Item_readIntoERP_ALL <- function(conn=conn_vm_erp_test()){

  item_list <-  Item_getList(conn = conn)
  ncount = nrow(item_list)

  if (ncount >0){

    lapply(1:ncount, function(i){
      MCode <- item_list$MCode[i]
      MProp <-  item_list$MProp[i]
      PLMBatchnum <- item_list$PLMBatchnum[i]

      #写入物料,增加容错错误
      try({
        Item_readIntoERP_One(conn=conn,MCode = MCode,MProp = MProp,PLMBatchnum = PLMBatchnum)
      })









    })


  }


}

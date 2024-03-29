% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/D03_PLM2ERP_Item.R
\name{PLM_Item_readByBatchNo_ZZ_New}
\alias{PLM_Item_readByBatchNo_ZZ_New}
\title{获取自制物料的信息信息}
\usage{
PLM_Item_readByBatchNo_ZZ_New(
  config_file = "config/conn_tc.R",
  batchNo = "APP00000005",
  conn_erp = conn_vm_erp_test()
)
}
\arguments{
\item{config_file}{配置}

\item{batchNo}{批号}

\item{conn_erp}{ERP链接}
}
\value{
返回值
}
\description{
获取自制物料的信息信息
}
\examples{
PLM_Item_readByBatchNo_ZZ_New()
}

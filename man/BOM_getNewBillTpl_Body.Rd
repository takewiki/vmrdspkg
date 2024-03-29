% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/D04_PLM2ERP_Bom.R
\name{BOM_getNewBillTpl_Body}
\alias{BOM_getNewBillTpl_Body}
\title{获取BOM新增的模板_表体部分}
\usage{
BOM_getNewBillTpl_Body(
  conn = conn_vm_erp_test(),
  PMCode = "2.104.20.00034",
  PLMBatchnum = "BOM00000002",
  FInterID = 0
)
}
\arguments{
\item{conn}{连接}

\item{PMCode}{更新产品编码}

\item{PLMBatchnum}{批号}

\item{FInterID}{id}
}
\value{
返回值
}
\description{
获取BOM新增的模板_表体部分
}
\examples{
BOM_getNewBillTpl_Body()
}

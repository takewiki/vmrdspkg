% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/A_conn.R
\name{conn_config_write}
\alias{conn_config_write}
\title{写入配置文件}
\usage{
conn_config_write(
  file_name = "config/conn_erp.xlsx",
  ip = "123.207.201.140",
  port = 1433,
  user_name = "sa",
  password = "rds@123",
  db_name = "AIS20140904110155"
)
}
\arguments{
\item{file_name}{文件名}

\item{ip}{地址}

\item{port}{端口}

\item{user_name}{用户名}

\item{password}{密码}

\item{db_name}{数据库名称}
}
\value{
返回值
}
\description{
写入配置文件
}
\examples{
conn_config_write()
}

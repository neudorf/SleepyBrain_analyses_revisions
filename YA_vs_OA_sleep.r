OA_wd_sleep = c(7.00,
                9.50,
                8.5,
                8.5,
                7.70,
                8.5,
                8.50,
                7,
                9.5,
                9,
                8.00,
                8.30,
                8.00,
                9.00,
                9.00,
                8.30,
                7.5,
                8.5,
                7.5
)
YA_wd_sleep = c(8.5,
                7.75,
                8.00,
                10,
                8.50,
                10,
                7,
                9.5,
                7.75,
                11,
                7.7,
                7.5,
                8.5,
                7.25,
                9,
                8.50,
                8,
                8,
                8,
                10,
                8,
                6.5,
                8
)

OA_we_sleep = c(7.7,
                     9,
                     9.5,
                     8.5,
                     7.7,
                     8.5,
                     8.6,
                     7,
                     9.5,
                     9.75,
                     8.7,
                     10,
                     7,
                     9,
                     10,
                     9,
                     7.5,
                     8.5,
                     9
)
YA_we_sleep =  c(8,
                      9.5,
                      8.7,
                      6,
                      8,
                      9,
                      8.5,
                      10.75,
                      9,
                      10,
                      8.5,
                      9,
                      7.75,
                      8.5,
                      9,
                      8.5,
                      9,
                      9.5,
                      7,
                      9,
                      8,
                      9,
                      8
)

YA_wd_mean = mean(YA_wd_sleep)
OA_wd_mean = mean(OA_wd_sleep)
YA_we_mean = mean(YA_we_sleep)
OA_we_mean = mean(OA_we_sleep)
YA_wd_sd = sd(YA_wd_sleep)
OA_wd_sd = sd(OA_wd_sleep)
YA_we_sd = sd(YA_we_sleep)
OA_we_sd = sd(OA_we_sleep)

t.test(YA_wd_sleep,OA_wd_sleep,var.equal=TRUE)
t.test(YA_we_sleep,OA_we_sleep,var.equal=TRUE)

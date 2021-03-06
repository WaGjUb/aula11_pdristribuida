library(plyr)
library(ggplot2)
library(scales) # to access break formatting functions
#library(pdf)

# Multiple plot function
#
# ggplot objects can be passed in ..., or to plotlist (as a list of ggplot objects)
# - cols:   Number of columns in layout
# - layout: A matrix specifying the layout. If present, 'cols' is ignored.
#
# If the layout is something like matrix(c(1,2,3,3), nrow=2, byrow=TRUE),
# then plot 1 will go in the upper left, 2 will go in the upper right, and
# 3 will go all the way across the bottom.
#
multiplot <- function(..., plotlist=NULL, file, cols=1, layout=NULL) {
  library(grid)

  # Make a list from the ... arguments and plotlist
  plots <- c(list(...), plotlist)

  numPlots = length(plots)

  # If layout is NULL, then use 'cols' to determine layout
  if (is.null(layout)) {
    # Make the panel
    # ncol: Number of columns of plots
    # nrow: Number of rows needed, calculated from # of cols
    layout <- matrix(seq(1, cols * ceiling(numPlots/cols)),
                    ncol = cols, nrow = ceiling(numPlots/cols))
  }

 if (numPlots==1) {
    print(plots[[1]])

  } else {
    # Set up the page
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))

    # Make each plot, in the correct location
    for (i in 1:numPlots) {
      # Get the i,j matrix positions of the regions that contain this subplot
      matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))

      print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                      layout.pos.col = matchidx$col))
    }
  }
}

# Insert rows in data frame.
# Usage: 
# r <- nrow(existingDF) + 1
# newrow <- c(2,3,4,5)
# insertRow(existingDF, newrow, r)
# insertRow(existingDF, c(9,6,3,1), 1)
insertRow <- function(existingDF, newrow, r) {
  existingDF[seq(r+1,nrow(existingDF)+1),] <- existingDF[seq(r,nrow(existingDF)),]
  existingDF[r,] <- newrow
  existingDF
}

##meus dados
setwd("/home/todos/alunos/cm/a1625381/Área de trabalho/aula11_pdristribuida");

# Load data about OMP, CUDA, OMP_OFF.
##abre dados do csv
data = read.csv("./src/codigo-suporte/terreno.csv");
View(data)

data <- subset(data, schedule == "STATIC" & size_of_data == 8388608)

cdata <- ddply(data, c("exp", "version", "schedule",  "chunk_size", "num_threads", "size_of_data"), summarise,
                   N    = length(chunk_size),
                   mean_orig = mean(ORIG),
                   mean_omp = mean(OMP),
                  # mean_omp_off = mean(OMP_OFF),
                  # mean_cuda_kernel_1 = mean(CUDA_KERNEL1),
                  # mean_cuda_kernel_2 = mean(CUDA_KERNEL2),
                  # mean_cuda_kernel_3 = mean(CUDA_KERNEL3),
                  # mean_cuda = mean_cuda_kernel_1 + mean_cuda_kernel_2 + mean_cuda_kernel_3,
                  # mean_dt_h2d = mean(DT_H2D),
                  # mean_dt_d2h = mean(DT_D2H),
                   
                   sd_orig = 2 * sd(ORIG),
                   sd_omp = 2 * sd(OMP),
                  # sd_omp_off = 2 * sd(OMP_OFF),
                  # sd_cuda_kernel_1 = 2 * sd(CUDA_KERNEL1),
                  # sd_cuda_kernel_2 = 2 * sd(CUDA_KERNEL2),
                  # sd_cuda_kernel_3 = 2 * sd(CUDA_KERNEL3),
                  # sd_cuda = sd_cuda_kernel_1 + sd_cuda_kernel_2 + sd_cuda_kernel_3,
                  # sd_dt_h2d = 2 * sd(DT_H2D),
                  # sd_dt_d2h = 2 * sd(DT_D2H),
                   
                   se_orig = sd_orig / sqrt(N),
                   se_omp = sd_omp / sqrt(N),
                  # se_omp_off = sd_omp_off / sqrt(N),
                  # se_cuda_kernel_1 = sd_cuda_kernel_1 / sqrt(N),
                  # se_cuda_kernel_2 = sd_cuda_kernel_2 / sqrt(N),
                  # se_cuda_kernel_3 = sd_cuda_kernel_3 / sqrt(N),
                  # se_cuda = se_cuda_kernel_1 + se_cuda_kernel_2 + se_cuda_kernel_3,
                  # se_dt_h2d = sd_dt_h2d / sqrt(N),
                  # se_dt_d2h = sd_dt_d2h / sqrt(N),
                   
                   mean_plot_value = 0.0,
                   se_plot_value = 0.0,
                   sd_plot_value = 0.0
                  # sum_work_finish_before_offload_decision = sum(WORK_FINISHED_BEFORE_OFFLOAD_DECISION),
                  # sum_reach_offload_decision_point = sum(REACH_OFFLOAD_DECISION_POINT),
                  # sum_decided_by_offloading = sum(DECIDED_BY_OFFLOADING),
                  # sum_made_the_offloading = sum(MADE_THE_OFFLOADING)
)



View(cdata)

# Prepare column to plot.
cdata$mean_plot_value  <- ifelse(cdata$version == "OMP", cdata$mean_omp, ifelse(cdata$version == "OMP+OFF", cdata$mean_omp_off, cdata$mean_cuda))
cdata$sd_plot_value  <- ifelse(cdata$version == "OMP", cdata$sd_omp, ifelse(cdata$version == "OMP+OFF", cdata$sd_omp_off, cdata$sd_cuda))
cdata$se_plot_value  <- ifelse(cdata$version == "OMP", cdata$se_omp, ifelse(cdata$version == "OMP+OFF", cdata$se_omp_off, cdata$se_cuda))

#test <-subset(cdata, version == "OMP+OFF")
#write.csv(test, file = "gemm-execucoes-nao-alcancaram-ponto-decisao.csv")

#    exp     size_of_data  N  mean_orig mean_cuda      sd_orig    sd_cuda      se_orig
df_data = data.frame(x=cdata$num_threads, y=cdata$chunk_size, z=cdata$mean_orig, z_se=cdata$se_orig, z_sd=cdata$sd_orig, t=cdata$mean_plot_value, t_se=cdata$se_plot_value, t_sd=cdata$sd_plot_value, cat=cdata$version)
df_data$x = as.factor(df_data$x)
df_data$y = as.factor(df_data$y)

View(df_data)
# Chunk size 16.
# Chunk size 0 is CUDA version.
# df_plot_16 <- subset(df_data, y== 16 | y == 0)
df_plot_16 <- subset(df_data, y== 16)

View(df_plot_16)

# write.csv(df_plot, file = "chunk_size_evaluation_df_plot.csv")

# df_plot = read.csv("/dados/rogerio/USP/doutorado/prova-de-conceito/testes-prova-conceito/openmp-hook/experiments/chunk_size_evaluation/graph/chunk_size_evaluation_df_plot.csv");
# View(df_plot)

#pdf(filename="evaluating-chunk_size-benchmark-gemm-data-extralarge_dataset-num_threads-1-a-24-dynamic-chunk_size-16.pdf", width=1200, height=800);
png("img16.png")
p1 <- ggplot(df_plot_16, aes(x=x, y=t, fill=cat)) + 
  geom_bar(stat="identity", position="dodge") +
  geom_errorbar(aes(ymin=t-t_sd, ymax=t+t_sd),
                size=.5,    # Thinner lines
                width=.4,
                position=position_dodge(.9)) + 
  xlab("Number of Threads") +
  ylab("Time(ms)") +
  #scale_fill_manual(name="Experiment", # Legend label, use darker colors
  #           breaks=c("OMP+OFF", "OMP"),
  #           labels=c("OMP+OFF", "OMP"), values=c("#494949", "#927080", "#B6B6B6")) +
  ggtitle("(Number of Threads with chunk_size = 16)\n") +
  # scale_y_continuous(trans='log') +
  scale_y_continuous() +
  # scale_y_log10() +
  theme_bw() +
  #theme(legend.position=c(0.89,0.70), legend.title=element_blank())
  theme(legend.position=c(0.9,0.89), legend.title=element_blank(), plot.title = element_text(size=20))

(p1 = p1 + scale_fill_grey(start = 0.9, end = 0.2))
multiplot(p1, cols=1)
#dev.copy2pdf(file = "evaluating-chunk_size-benchmark-gemm-data-extralarge_dataset-num_threads-1-a-24-dynamic-chunk_size-16.pdf");
 dev.off ();

# Chunk size 32.
#df_plot_32 <- subset(df_data, y== 32 | y == 0)
df_plot_32 <- subset(df_data, y== 32)

View(df_plot_32)

# write.csv(df_plot, file = "chunk_size_evaluation_df_plot.csv")

# df_plot = read.csv("/dados/rogerio/USP/doutorado/prova-de-conceito/testes-prova-conceito/openmp-hook/experiments/chunk_size_evaluation/graph/chunk_size_evaluation_df_plot.csv");
# View(df_plot)

#pdf(filename="evaluating-chunk_size-benchmark-gemm-data-extralarge_dataset-num_threads-1-a-24-dynamic-chunk_size-32.pdf", width=1200, height=800);
png("img32.png")
p2 <- ggplot(df_plot_32, aes(x=x, y=t, fill=cat)) + 
  geom_bar(stat="identity", position="dodge") +
  geom_errorbar(aes(ymin=t-t_sd, ymax=t+t_sd),
                size=.5,    # Thinner lines
                width=.4,
                position=position_dodge(.9)) + 
  xlab("Number of Threads") +
  ylab("Time(ms)") +
  #scale_fill_manual(name="Experiment", # Legend label, use darker colors
  #           breaks=c("OMP+OFF", "OMP"),
  #           labels=c("OMP+OFF", "OMP"), values=c("#494949", "#927080", "#B6B6B6")) +
  ggtitle("(Number of Threads with chunk_size = 32)\n") +
  # scale_y_continuous(trans='log') +
  scale_y_continuous() +
  # scale_y_log10() +
  theme_bw() +
  #theme(legend.position=c(0.89,0.70), legend.title=element_blank())
  theme(legend.position=c(0.9,0.89), legend.title=element_blank(), plot.title = element_text(size=20))

(p2 = p2 + scale_fill_grey(start = 0.9, end = 0.2))

multiplot(p2, cols=1)
 dev.off ();

# Chunk size 64.
# df_plot_64 <- subset(df_data, y== 64 | y == 0)
df_plot_64 <- subset(df_data, y== 64)

View(df_plot_64)

# write.csv(df_plot, file = "chunk_size_evaluation_df_plot.csv")

# df_plot = read.csv("/dados/rogerio/USP/doutorado/prova-de-conceito/testes-prova-conceito/openmp-hook/experiments/chunk_size_evaluation/graph/chunk_size_evaluation_df_plot.csv");
# View(df_plot)

#pdf(filename="evaluating-chunk_size-benchmark-gemm-data-extralarge_dataset-num_threads-1-a-24-dynamic-chunk_size-32.pdf", width=1200, height=800);
png("img64.png")
p3 <- ggplot(df_plot_64, aes(x=x, y=t, fill=cat)) + 
  geom_bar(stat="identity", position="dodge") +
  geom_errorbar(aes(ymin=t-t_sd, ymax=t+t_sd),
                size=.5,    # Thinner lines
                width=.4,
                position=position_dodge(.9)) + 
  xlab("Number of Threads") +
  ylab("Time(ms)") +
  #scale_fill_manual(name="Experiment", # Legend label, use darker colors
  #           breaks=c("OMP+OFF", "OMP"),
  #           labels=c("OMP+OFF", "OMP"), values=c("#494949", "#927080", "#B6B6B6")) +
  ggtitle("(Number of Threads with chunk_size = 64)\n") +
  # scale_y_continuous(trans='log') +
  scale_y_continuous() +
  # scale_y_log10() +
  theme_bw() +
  #theme(legend.position=c(0.89,0.70), legend.title=element_blank())
  theme(legend.position=c(0.9,0.89), legend.title=element_blank(), plot.title = element_text(size=20))

(p3 = p3 + scale_fill_grey(start = 0.9, end = 0.2))

multiplot(p3, cols=1)
#dev.copy2pdf(file = "evaluating-chunk_size-benchmark-gemm-data-extralarge_dataset-num_threads-1-a-24-dynamic-chunk_size-64.pdf");
 dev.off ();

# Chunk size 128.
#df_plot_128 <- subset(df_data, y== 128 | y == 0)
df_plot_128 <- subset(df_data, y== 128)

View(df_plot_128)

# write.csv(df_plot, file = "chunk_size_evaluation_df_plot.csv")

# df_plot = read.csv("/dados/rogerio/USP/doutorado/prova-de-conceito/testes-prova-conceito/openmp-hook/experiments/chunk_size_evaluation/graph/chunk_size_evaluation_df_plot.csv");
# View(df_plot)

#pdf(filename="evaluating-chunk_size-benchmark-gemm-data-extralarge_dataset-num_threads-1-a-24-dynamic-chunk_size-128.pdf", width=1200, height=800);
png("img128.png")
Offloading("image.Offloading", width = 531, height = 413)
p4 <- ggplot(df_plot_128, aes(x=x, y=t, fill=cat)) + 
  geom_bar(stat="identity", position="dodge") +
  geom_errorbar(aes(ymin=t-t_sd, ymax=t+t_sd),
                size=.5,    # Thinner lines
                width=.4,
                position=position_dodge(.9)) + 
  xlab("Number of Threads") +
  ylab("Time(ms)") +
  #scale_fill_manual(name="Experiment", # Legend label, use darker colors
  #           breaks=c("OMP+OFF", "OMP"),
  #           labels=c("OMP+OFF", "OMP"), values=c("#494949", "#927080", "#B6B6B6")) +
  ggtitle("(Number of Threads with chunk_size = 128)\n") +
  # scale_y_continuous(trans='log') +
  scale_y_continuous() +
  # scale_y_log10() +
  theme_bw() +
  #theme(legend.position=c(0.89,0.70), legend.title=element_blank())
  theme(legend.position=c(0.9,0.89), legend.title=element_blank(), plot.title = element_text(size=20))

(p4 = p4 + scale_fill_grey(start = 0.9, end = 0.2))

multiplot(p4, cols=1)
#dev.copy2pdf(file = "evaluating-chunk_size-benchmark-gemm-data-extralarge_dataset-num_threads-1-a-24-dynamic-chunk_size-128.pdf");
 dev.off ();

# Chunk size 256.
# df_plot_256 <- subset(df_data, y== 256 | y == 0)
df_plot_256 <- subset(df_data, y== 256)

View(df_plot_256)

# write.csv(df_plot, file = "chunk_size_evaluation_df_plot.csv")

# df_plot = read.csv("/dados/rogerio/USP/doutorado/prova-de-conceito/testes-prova-conceito/openmp-hook/experiments/chunk_size_evaluation/graph/chunk_size_evaluation_df_plot.csv");
# View(df_plot)

#pdf(filename="evaluating-chunk_size-benchmark-gemm-data-extralarge_dataset-num_threads-1-a-24-dynamic-chunk_size-256.pdf", width=1200, height=800);
png("img256.png")
p5 <- ggplot(df_plot_256, aes(x=x, y=t, fill=cat)) + 
  geom_bar(stat="identity", position="dodge") +
  geom_errorbar(aes(ymin=t-t_sd, ymax=t+t_sd),
                size=.5,    # Thinner lines
                width=.4,
                position=position_dodge(.9)) + 
 
  xlab("Number of Threads") +
  ylab("Time(ms)") +
  #scale_fill_manual(name="Experiment", # Legend label, use darker colors
  #           breaks=c("OMP+OFF", "OMP"),
  #           labels=c("OMP+OFF", "OMP"), values=c("#494949", "#927080", "#B6B6B6")) +
  ggtitle("(Number of Threads with chunk_size = 256)\n") +
  # scale_y_continuous(trans='log') +
  scale_y_continuous() +
  # scale_y_log10() +
  theme_bw() +
  #theme(legend.position=c(0.89,0.70), legend.title=element_blank())
  theme(legend.position=c(0.9,0.89), legend.title=element_blank(), plot.title = element_text(size=20))

(p5 = p5 + scale_fill_grey(start = 0.9, end = 0.2))

multiplot(p5, cols=1)
#####dev.copy2pdf(file = "evaluating-chunk_size-benchmark-gemm-data-extralarge_dataset-num_threads-1-a-24-dynamic-chunk_size-256.pdf");
 dev.off ();



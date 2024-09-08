###+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
### CONFIGURANDO O AMBIENTE DE CODACAO (1)
###+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# Nesta secao, sao feitos: (a) limpeza do environment e liberacao de memoria;
# (b) ajustes nas configuracoes padroes do softuware referentes a mensagens de
# erros e exibicao de numeros exponenciais; e (c) instalacao e carregamento de
# pacotes necessarios para manipulaco dos microdados da POF 2017/2018.

### Preparando o ambiente (1.1)

rm(list = ls())

aviso = getOption('warn')
options(warn = -1)
options(encoding = 'latin1')
options(warn = aviso)
rm(aviso)

aviso = getOption('warn')
options(warn = -1)
options(scipen = 999)
options(warn = aviso)
rm(aviso)

### Instalando pacotes (1.2)

install.packages("tidyverse")
install.packages("geobr")
install.packages("openxlsx")
install.packages("patchwork")
install.packages("sf")
install.packages("wesanderson")
install.packages("viridis")
install.packages("archive")
install.packages("readxl")
install.packages("httr")
install.packages("readr")
install.packages("survey")

### Carregando pacotes (1.3)

library("tidyverse")
library("geobr")
library("openxlsx")
library("patchwork")
library("sf")
library("wesanderson")
library("viridis")
library("archive")
library("readxl")
library("httr")
library("readr")
library("survey")

###+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
### IMPORTACAO DOS MICRODADOS DA POF 2017-2018 (2)
###+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# Nesta secao, os microdados de cada caderno de pesquisa da POF 2017/2018 sao
# carregados e estruturados para salvamento no formato padrao do R (Rds)

### Baixar documentacao dos microdados da POF (2.1)
# Caminho para o arquivo documentacao no site do IBGE

url_diconario = "https://ftp.ibge.gov.br/Orcamentos_Familiares/Pesquisa_de_Orcamentos_Familiares_2017_2018/Microdados/Documentacao_20230713.zip"

# Arquivo temperario dicionario

dic_temp = tempfile()

# Download do arquivo zip dicionario

download.file(url = url_diconario, destfile = dic_temp, mode = "wb")

# Descompactacao dos arquivos para o diretorio temporario

documentacao <- archive_extract(dic_temp, dir = tempdir())

# Carregameto do diconario de variaveis

dicionario = file.path(tempdir(), "Dicionários de váriaveis.xls")

### Baixar dados da POF (2.2)
# Caminho para o arquivo documentacao no site do IBGE

url_dados = "https://ftp.ibge.gov.br/Orcamentos_Familiares/Pesquisa_de_Orcamentos_Familiares_2017_2018/Microdados/Dados_20230713.zip"

# Arquivo temperario dados

dados_temp = tempfile()

# Download do arquivo zip dados
# Nesse caso foi necessario aaumentar o tempo de consulta, devido ao volume de dados

options(timeout = 600)

try(download.file(url = url_dados, destfile = dados_temp, mode = "wb"))

# Descompactacao dos cadernos de microdados para o diretorio temporario

cadernos = unzip(dados_temp, exdir = tempdir())

### Caderno de microdados de domicilio (2.3)
# Conforme dicionario dos microdados de domicilio, estabelecimento dos pontos de
# de corte no caderno de microdadados

vars_dom = read_excel(dicionario, sheet = "Domicílio", skip = 3) %>%
  mutate("Inicio" = as.integer(`Posição Inicial`),
         "Corte" = as.integer(Tamanho),
         "Decimais" = as.integer(Decimais),
         "Variavel" = `Código da variável`,
         "Descricao" = Descrição,
         "Rotulos" = Categorias) %>%
  select(Inicio, Corte, Decimais, Variavel, Descricao, Rotulos) %>%
  filter(!is.na(Inicio))

# Microdados do Domicilio

Domicilio = read_fwf(file = grep('DOMICILIO\\.txt$', cadernos, value = T),
                     fwf_widths(widths = vars_dom$Corte,
                                col_names = vars_dom$Variavel))

# Armazena no HD local arquivo serializado para leituras futuras

saveRDS(Domicilio,"DOMICILIO.rds")

rm(Domicilio, vars_dom)

### Caderno de microdados de morador (2.4)
# Conforme dicionario dos microdados de morador, estabelecimento dos pontos de
# de corte no caderno de microdadados

vars_mor = read_excel(dicionario, sheet = "Morador", skip = 3) %>%
  mutate("Inicio" = as.integer(`Posição Inicial`),
         "Corte" = as.integer(Tamanho),
         "Decimais" = as.integer(Decimais),
         "Variavel" = `Código da variável`,
         "Descricao" = Descrição,
         "Rotulos" = Categorias) %>%
  select(Inicio, Corte, Decimais, Variavel, Descricao, Rotulos) %>%
  filter(!is.na(Inicio))

# Microdados do Morador

Morador = read_fwf(file = grep('MORADOR\\.txt$', cadernos, value = T),
                   fwf_widths(widths = vars_mor$Corte,
                              col_names = vars_mor$Variavel))

# Armazena no HD local arquivo serializado para leituras futuras

saveRDS(Morador,"MORADOR.rds")

rm(Morador, vars_mor)

### Caderno de microdados de qualidade de vida dos moradores (2.5)
# Conforme dicionario dos microdados de qualidade de vida dos moradores, 
# estabelecimento dos pontos de corte no caderno de microdadados

vars_mor2 = read_excel(dicionario, sheet = "Morador - Qualidade de Vida", skip = 2) %>%
  mutate("Inicio" = as.integer(`Posição Inicial`),
         "Corte" = as.integer(Tamanho),
         "Decimais" = as.integer(Decimais),
         "Variavel" = `Código da variável`,
         "Descricao" = Descrição,
         "Rotulos" = Categorias) %>%
  select(Inicio, Corte, Decimais, Variavel, Descricao, Rotulos) %>%
  filter(!is.na(Inicio))

# Microdados do Morador_Q_V

Morador_Q_V = read_fwf(file = grep('MORADOR_QUALI_VIDA\\.txt$', cadernos, value = T),
                       fwf_widths(widths = vars_mor2$Corte,
                                  col_names = vars_mor2$Variavel))

# Armazena no HD local arquivo serializado para leituras futuras

saveRDS(Morador_Q_V,"MORADOR_QUALI_VIDA.rds")

rm(Morador_Q_V, vars_mor2)

### Caderno de microdados de aluguel estimado (2.6)
# Conforme dicionario dos microdados aluguel estimado, estabelecimento dos pontos 
# de corte no caderno de microdadados

vars_alug = read_excel(dicionario, sheet = "Aluguel Estimado", skip = 3) %>%
  mutate("Inicio" = as.integer(`Posição Inicial`),
         "Corte" = as.integer(Tamanho),
         "Decimais" = as.integer(Decimais),
         "Variavel" = `Código da variável`,
         "Descricao" = Descrição,
         "Rotulos" = Categorias) %>%
  select(Inicio, Corte, Decimais, Variavel, Descricao, Rotulos) %>%
  filter(!is.na(Inicio))

# Microdados do Aluguel

Aluguel = read_fwf(file = grep('ALUGUEL_ESTIMADO\\.txt$', cadernos, value = T),
                   fwf_widths(widths = vars_alug$Corte,
                              col_names = vars_alug$Variavel))

# Armazena no HD local arquivo serializado para leituras futuras

saveRDS(Aluguel,"ALUGUEL_ESTIMADO.rds")

rm(Aluguel, vars_alug)

### Caderno de microdados de despesa coletiva (2.7)
# Conforme dicionario dos microdados despesa coletiva, estabelecimento dos pontos 
# de corte no caderno de microdadados

vars_D_C = read_excel(dicionario, sheet = "Despesa Coletiva", skip = 3) %>%
  mutate("Inicio" = as.integer(`Posição Inicial`),
         "Corte" = as.integer(Tamanho),
         "Decimais" = as.integer(Decimais),
         "Variavel" = `Código da variável`,
         "Descricao" = Descrição,
         "Rotulos" = Categorias) %>%
  select(Inicio, Corte, Decimais, Variavel, Descricao, Rotulos) %>%
  filter(!is.na(Inicio))

# Microdados do Desp_col

Desp_col = read_fwf(file = grep('DESPESA_COLETIVA\\.txt$', cadernos, value = T),
                    fwf_widths(widths = vars_D_C$Corte,
                               col_names = vars_D_C$Variavel))

# Armazena no HD local arquivo serializado para leituras futuras

saveRDS(Desp_col,"DESPESA_COLETIVA.rds")

rm(Desp_col, vars_D_C)

### Caderno de microdados de servicos nao monetarios (2.8)
# Conforme dicionario dos microdados servicos nao monetarios, estabelecimento 
# dos pontos  de corte no caderno de microdadados

vars_SNM = read_excel(dicionario, sheet = "Serviços Não Monetários - POF 2", skip = 3) %>%
  mutate("Inicio" = as.integer(`Posição Inicial`),
         "Corte" = as.integer(Tamanho),
         "Decimais" = as.integer(Decimais),
         "Variavel" = `Código da variável`,
         "Descricao" = Descrição,
         "Rotulos" = Categorias) %>%
  select(Inicio, Corte, Decimais, Variavel, Descricao, Rotulos) %>%
  filter(!is.na(Inicio))

# Microdados do Serv_NM

Serv_NM = read_fwf(file = grep('SERVICO_NAO_MONETARIO_POF2\\.txt$', cadernos, value = T),
                   fwf_widths(widths = vars_SNM$Corte,
                              col_names = vars_SNM$Variavel))

# Armazena no HD local arquivo serializado para leituras futuras

saveRDS(Serv_NM,"SERVICO_NAO_MONETARIO_POF2.rds")

rm(Serv_NM, vars_SNM)

### Caderno de microdados de inventario de bens duraveis (2.9)
# Conforme dicionario dos microdados inventario de bens duraveis, estabelecimento 
# dos pontos  de corte no caderno de microdadados

vars_IBD = read_excel(dicionario, sheet = "Inventário", skip = 3) %>%
  mutate("Inicio" = as.integer(`Posição Inicial`),
         "Corte" = as.integer(Tamanho),
         "Decimais" = as.integer(Decimais),
         "Variavel" = `Código da variável`,
         "Descricao" = Descrição,
         "Rotulos" = Categorias) %>%
  select(Inicio, Corte, Decimais, Variavel, Descricao, Rotulos) %>%
  filter(!is.na(Inicio))

# Microdados do Inventario

Inventario = read_fwf(file = grep('INVENTARIO\\.txt$', cadernos, value = T),
                      fwf_widths(widths = vars_IBD$Corte,
                                 col_names = vars_IBD$Variavel))

# Armazena no HD local arquivo serializado para leituras futuras

saveRDS(Inventario,"INVENTARIO.rds")

rm(Inventario, vars_IBD)

### Caderno de microdados de caderneta coletiva (2.10)
# Conforme dicionario dos microdados caderneta coletiva, estabelecimento 
# dos pontos  de corte no caderno de microdadados

vars_CC = read_excel(dicionario, sheet = "Caderneta Coletiva", skip = 3) %>%
  mutate("Inicio" = as.integer(`Posição Inicial`),
         "Corte" = as.integer(Tamanho),
         "Decimais" = as.integer(Decimais),
         "Variavel" = `Código da variável`,
         "Descricao" = Descrição,
         "Rotulos" = Categorias) %>%
  select(Inicio, Corte, Decimais, Variavel, Descricao, Rotulos) %>%
  filter(!is.na(Inicio))

# Microdados da Cad_col

Cad_col = read_fwf(file = grep('CADERNETA_COLETIVA\\.txt$', cadernos, value = T),
                   fwf_widths(widths = vars_CC$Corte,
                              col_names = vars_CC$Variavel))

# Armazena no HD local arquivo serializado para leituras futuras

saveRDS(Cad_col,"CADERNETA_COLETIVA.rds")

rm(Cad_col, vars_CC)

### Caderno de microdados de despesa individual (2.11)
# Conforme dicionario dos microdados despesa individual, estabelecimento 
# dos pontos  de corte no caderno de microdadados

vars_DI = read_excel(dicionario, sheet = "Despesa Individual", skip = 3) %>%
  mutate("Inicio" = as.integer(`Posição Inicial`),
         "Corte" = as.integer(Tamanho),
         "Decimais" = as.integer(Decimais),
         "Variavel" = `Código da variável`,
         "Descricao" = Descrição,
         "Rotulos" = Categorias) %>%
  select(Inicio, Corte, Decimais, Variavel, Descricao, Rotulos) %>%
  filter(!is.na(Inicio))

# Microdados de Desp_ind

Desp_ind = read_fwf(file = grep('DESPESA_INDIVIDUAL\\.txt$', cadernos, value = T),
                    fwf_widths(widths = vars_DI$Corte,
                               col_names = vars_DI$Variavel))

# Armazena no HD local arquivo serializado para leituras futuras

saveRDS(Desp_ind,"DESPESA_INDIVIDUAL.rds")

rm(Desp_ind, vars_DI)

### Caderno de microdados de servicos nao monetarios - POF 4 (2.12)
# Conforme dicionario dos microdados servicos nao monetarios - POF 4, estabelecimento 
# dos pontos  de corte no caderno de microdadados

vars_SNM2 = read_excel(dicionario, sheet = "Serviços Não Monetários - POF 4", skip = 3) %>%
  mutate("Inicio" = as.integer(`Posição Inicial`),
         "Corte" = as.integer(Tamanho),
         "Decimais" = as.integer(Decimais),
         "Variavel" = `Código da variável`,
         "Descricao" = Descrição,
         "Rotulos" = Categorias) %>%
  select(Inicio, Corte, Decimais, Variavel, Descricao, Rotulos) %>%
  filter(!is.na(Inicio))

# Microdados de Serv_NM2

Serv_NM2 = read_fwf(file = grep('SERVICO_NAO_MONETARIO_POF4\\.txt$', cadernos, value = T),
                    fwf_widths(widths = vars_SNM2$Corte,
                               col_names = vars_SNM2$Variavel))

# Armazena no HD local arquivo serializado para leituras futuras

saveRDS(Serv_NM2,"SERVICO_NAO_MONETARIO_POF4.rds")

rm(Serv_NM2, vars_SNM2)

### Caderno de microdados de produtos ou servicos de saude (2.13)
# Conforme dicionario dos microdados produtos ou servicos de saude, estabelecimento 
# dos pontos  de corte no caderno de microdadados

vars_saude = read_excel(dicionario, sheet = "Restrição - Saúde", skip = 3) %>%
  mutate("Inicio" = as.integer(`Posição Inicial`),
         "Corte" = as.integer(Tamanho),
         "Decimais" = as.integer(Decimais),
         "Variavel" = `Código da variável`,
         "Descricao" = Descrição,
         "Rotulos" = Categorias) %>%
  select(Inicio, Corte, Decimais, Variavel, Descricao, Rotulos) %>%
  filter(!is.na(Inicio))

# Microdados de Saude

Saude = read_fwf(file = grep('RESTRICAO_PRODUTOS_SERVICOS_SAUDE\\.txt$', cadernos, value = T),
                 fwf_widths(widths = vars_saude$Corte,
                            col_names = vars_saude$Variavel))

# Armazena no HD local arquivo serializado para leituras futuras

saveRDS(Saude,"RESTRICAO_PRODUTOS_SERVICOS_SAUDE.rds")

rm(Saude, vars_saude)

### Caderno de microdados de rendimnento do trabalho (2.14)
# Conforme dicionario dos microdados rendimnento do trabalho, estabelecimento 
# dos pontos  de corte no caderno de microdadados

vars_rend = read_excel(dicionario, sheet = "Rendimento do Trabalho", skip = 3) %>%
  mutate("Inicio" = as.integer(`Posição Inicial`),
         "Corte" = as.integer(Tamanho),
         "Decimais" = as.integer(Decimais),
         "Variavel" = `Código da variável`,
         "Descricao" = Descrição,
         "Rotulos" = Categorias) %>%
  select(Inicio, Corte, Decimais, Variavel, Descricao, Rotulos) %>%
  filter(!is.na(Inicio))

# Microdados de Rend_trab

Rend_trab = read_fwf(file = grep('RENDIMENTO_TRABALHO\\.txt$', cadernos, value = T),
                     fwf_widths(widths = vars_rend$Corte,
                                col_names = vars_rend$Variavel))

# Armazena no HD local arquivo serializado para leituras futuras

saveRDS(Rend_trab,"RENDIMENTO_TRABALHO.rds")

rm(Rend_trab, vars_rend)

### Caderno de microdados de outros rendimnentos (2.15)
# Conforme dicionario dos microdados outros rendimnentos, estabelecimento 
# dos pontos  de corte no caderno de microdadados

vars_outros = read_excel(dicionario, sheet = "Outros Rendimentos", skip = 3) %>%
  mutate("Inicio" = as.integer(`Posição Inicial`),
         "Corte" = as.integer(Tamanho),
         "Decimais" = as.integer(Decimais),
         "Variavel" = `Código da variável`,
         "Descricao" = Descrição,
         "Rotulos" = Categorias) %>%
  select(Inicio, Corte, Decimais, Variavel, Descricao, Rotulos) %>%
  filter(!is.na(Inicio))

# Microdados de Rend_out

Rend_out = read_fwf(file = grep('OUTROS_RENDIMENTOS\\.txt$', cadernos, value = T),
                    fwf_widths(widths = vars_outros$Corte,
                               col_names = vars_outros$Variavel))

# Armazena no HD local arquivo serializado para leituras futuras

saveRDS(Rend_out,"OUTROS_RENDIMENTOS.rds")

rm(Rend_out, vars_outros)

### Caderno de microdados de condicoes de vida (2.16)
# Conforme dicionario dos microdados condicoes de vida, estabelecimento 
# dos pontos  de corte no caderno de microdadados

vars_vida = read_excel(dicionario, sheet = "Condições de Vida", skip = 2) %>%
  mutate("Inicio" = as.integer(`Posição Inicial`),
         "Corte" = as.integer(Tamanho),
         "Decimais" = as.integer(Decimais),
         "Variavel" = `Código da variável`,
         "Descricao" = Descrição,
         "Rotulos" = Categorias) %>%
  select(Inicio, Corte, Decimais, Variavel, Descricao, Rotulos) %>%
  filter(!is.na(Inicio))

# Microdados de Cond_vida

Cond_vida = read_fwf(file = grep('CONDICOES_VIDA\\.txt$', cadernos, value = T),
                     fwf_widths(widths = vars_vida$Corte,
                                col_names = vars_vida$Variavel))

# Armazena no HD local arquivo serializado para leituras futuras

saveRDS(Cond_vida,"CONDICOES_VIDA.rds")

rm(Cond_vida, vars_vida)

### Caderno de microdados de caracteristicas da dieta (2.17)
# Conforme dicionario dos microdados caracteristicas da dieta, estabelecimento 
# dos pontos  de corte no caderno de microdadados

vars_dieta = read_excel(dicionario, sheet = "Características da Dieta", skip = 3) %>%
  mutate("Inicio" = as.integer(`Posição Inicial`),
         "Corte" = as.integer(Tamanho),
         "Decimais" = as.integer(Decimais),
         "Variavel" = `Código da variável`,
         "Descricao" = Descrição,
         "Rotulos" = Categorias) %>%
  select(Inicio, Corte, Decimais, Variavel, Descricao, Rotulos) %>%
  filter(!is.na(Inicio))

# Microdados de Dieta

Dieta = read_fwf(file = grep('CARACTERISTICAS_DIETA\\.txt$', cadernos, value = T),
                 fwf_widths(widths = vars_dieta$Corte,
                            col_names = vars_dieta$Variavel))

# Armazena no HD local arquivo serializado para leituras futuras

saveRDS(Dieta,"CARACTERISTICAS_DIETA.rds")

rm(Dieta, vars_dieta)

### Caderno de microdados de consumo alimentar (2.18)
# Conforme dicionario dos microdados consumo alimentar, estabelecimento 
# dos pontos  de corte no caderno de microdadados

vars_CA = read_excel(dicionario, sheet = "Consumo Alimentar", skip = 3) %>%
  mutate("Inicio" = as.integer(`Posição Inicial`),
         "Corte" = as.integer(Tamanho),
         "Decimais" = as.integer(Decimais),
         "Variavel" = `Código da variável`,
         "Descricao" = Descrição,
         "Rotulos" = Categorias) %>%
  select(Inicio, Corte, Decimais, Variavel, Descricao, Rotulos) %>%
  filter(!is.na(Inicio))

# Microdados de Cons_alim

Cons_alim = read_fwf(file = grep('CONSUMO_ALIMENTAR\\.txt$', cadernos, value = T),
                     fwf_widths(widths = vars_CA$Corte,
                                col_names = vars_CA$Variavel))

# Armazena no HD local arquivo serializado para leituras futuras

saveRDS(Cons_alim,"CONSUMO_ALIMENTAR.rds")

rm(Cons_alim, vars_CA)


###+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
### LIMPEZA E TRATAMENTO DOS MICRODADOS DA POF 2017-2018 (3)
###+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# Esta secao se baseia na estruturacao dos micreodados da secao anterior. Daqui
# em diante, sao criados objetos pelo carregamento dos arquios padroes do R, no
# no diretorio padrao, para estao se prosseguir no 'tidy' dos dados

### Carregamento dos cadernos de microdados (3.1)

## POF 1 - Caracteristicas do domicilio e dos moradores
# O POF 1 é um questionário estruturado em quatro Quadros que obedecem à 
# seguinte numeração: Quadro 1 - Identificação e controle do questionário;
# Quadro 2 - Características da habitação; Quadro 3 - Relação dos moradores; e

Domicilio = readRDS("DOMICILIO.rds")

Aluguel = readRDS("ALUGUEL_ESTIMADO.rds")

# Quadro 4 - Características do morador.

Morador = readRDS("MORADOR.rds")

Morador_qvida = readRDS("MORADOR_QUALI_VIDA.rds")

## POF 3 - Caderneta de Aquisicao coletiva
# Esta caderneta será utilizada para registrar as aquisições de alimentos ,
# bebidas artigos de limpeza e outros produtos , cuja aquisição costuma ser
# frequente e, em geral, serve em a todos os moradores do domicílio
# Quadro 62 - Identificação e controle do questionário; e
# Quadros 63 a 69 - Destinados ao registro das aquisições diárias de alimentos 
# (inclusive refeição pronta), bebidas, artigos de limpeza doméstica, artigos de 
# papel (papel higiênico, guardanapos de papel, papel toalha, etc.), fósforo,
# vela, flores naturais, carvão para churrasco e alimentos para animais domésticos.

Cad_coletiva = readRDS("CADERNETA_COLETIVA.rds")

## POF 2 - Questionario de aquisicao coletiva
# Neste questionário serão pesquisadas, nos respectivos períodos de referência de 
# cada Quadro: aquisições de produtos que, em geral, servem a todos os moradores 
# e cuja aquisição não é frequente (eletrodomésticos, móveis, etc.); utilização 
# de serviços de energia elétrica, gás, telefone, etc.; aquisição de combustíveis 
# domésticos e outros; consertos e aluguéis de aparelhos e utilidades de uso 
# doméstico; aquisições de produtos e serviços referentes a construção, reforma e
# pequenos reparos com habitação ou jazigo; utilização de serviços domésticos e 
# informações sobre diferentes tipos de bens duráveis existentes em condições de 
# uso no domicílio.

Desp_coletiva = readRDS("DESPESA_COLETIVA.rds")

POF_2 = readRDS("SERVICO_NAO_MONETARIO_POF2.rds")

Inventario = readRDS("INVENTARIO.rds")

## POF 4 - Questionario de aquisicao individual
# Neste questionário serão pesquisadas, nos respectivos períodos de referência 
# de cada Quadro, aquisições de produtos e serviços, em geral de utilização 
# pessoal (produtos farmacêuticos, transportes, alimentação fora do domicílio, 
# veículos, vestuário, etc.), não pesquisadas no POF 2 e no POF 3.

Desp_individual = readRDS("DESPESA_INDIVIDUAL.rds")

POF_4 = readRDS("SERVICO_NAO_MONETARIO_POF4.rds")

Saude = readRDS("RESTRICAO_PRODUTOS_SERVICOS_SAUDE.rds")

## POF 5 - Questionario de trabalho e rendimento individual
# As informações sobre as pessoas consideradas como Unidade de Orçamento-Trabalho 
# e/ou Rendimento serão registradas no POF 5. Assim, será preenchido, um 
# questionário POF 5 para cada Unidade de Orçamento-Trabalho e/ou Rendimento 
# encontrada na Unidade de Consumo do domicílio.

Rend = readRDS("RENDIMENTO_TRABALHO.rds")

Outros_rend = readRDS("OUTROS_RENDIMENTOS.rds")

## POF 6 - Avaliacao das condicoes de vida
# O POF 6 é um questionário com perguntas de caráter subjetivo que capta a 
# opinião/avaliação do entrevistado em uma sequência ordenada de perguntas e 
# deverá ser preenchido pela pessoa de referência de cada Unidade de Consumo do 
# domicílio ou, no caso de ausência do mesmo, por outra pessoa moradora da Unidade 
# de Consumo indicada pelos moradores presentes, que não seja empregado doméstico 
# ou parente de empregado doméstico

Cond_vida = readRDS("CONDICOES_VIDA.rds")

## POF 7 - Bloco de consumo alimentar pessoal
# O Bloco de Consumo Alimentar Pessoal (POF 7) será preenchido pelo Agente de 
# Pesquisa mediante entrevista pessoal para preencher dois dias de recordatório. 
# A intenção é pedir ao entrevistado que relate todos os alimentos e bebidas 
# consumidos no dia anterior à entrevista da hora em que acordou até a hora em 
# que foi dormir.

Carac_dieta = readRDS("CARACTERISTICAS_DIETA.rds")

Cons_alimentar = readRDS("CONSUMO_ALIMENTAR.rds")

### Manipulacao dos cadernos necessarios para calculos de despesas (3.2)
# Este passo utiliza os seguintes cadernos de microdados, contendo todas as despesas
# e gastos das unidades de consumo (familias): (a) Aluguel estimado; (b) caderneta
# de despesas coletivas; (c) Despesa coletiva; (d) Despesa individual; (e) Outros
# rendimentos; e (f) Rendimentos do trabalho.
# Criacao da tabela de despesas gerais = Despesas
# Ajustes necessario na base de despesas
# Variavel de Despesas anuais com bens e servicos = DESP_A
# Variavel de despesas anuais com INSS = INSS_A
# Variavel Contribuicao para a Previdencia Publica anual = CPP_A
# Variavel do Imposto de Renda Pessoa Fisica anual = IRPF_A
# Variavel Imposto sobre Serviços de Qualquer Natureza anual = ISSQN_A
# variavel de Deducoes anuais sobre rendimentos = DEDUCOES_A

Despesas = data.frame("UF" = c(Aluguel$UF, Cad_coletiva$UF, Desp_coletiva$UF,
                               Desp_individual$UF, Outros_rend$UF, Rend$UF),
                      "ESTRATO" = c(Aluguel$ESTRATO_POF, Cad_coletiva$ESTRATO_POF,
                                    Desp_coletiva$ESTRATO_POF, Desp_individual$ESTRATO_POF,
                                    Outros_rend$ESTRATO_POF, Rend$ESTRATO_POF),
                      "SIT_REG" = c(Aluguel$TIPO_SITUACAO_REG, Cad_coletiva$TIPO_SITUACAO_REG,
                                    Desp_coletiva$TIPO_SITUACAO_REG, Desp_individual$TIPO_SITUACAO_REG,
                                    Outros_rend$TIPO_SITUACAO_REG, Rend$TIPO_SITUACAO_REG),
                      "COD_UPA" = c(Aluguel$COD_UPA, Cad_coletiva$COD_UPA, Desp_coletiva$COD_UPA,
                                    Desp_individual$COD_UPA, Outros_rend$COD_UPA, Rend$COD_UPA),
                      "NUM_DOM" = c(Aluguel$NUM_DOM, Cad_coletiva$NUM_DOM, Desp_coletiva$NUM_DOM,
                                    Desp_individual$NUM_DOM, Outros_rend$NUM_DOM, Rend$NUM_DOM),
                      "NUM_UC" = c(Aluguel$NUM_UC, Cad_coletiva$NUM_UC, Desp_coletiva$NUM_UC,
                                   Desp_individual$NUM_UC, Outros_rend$NUM_DOM, Rend$NUM_UC),
                      "QUADRO" = c(Aluguel$QUADRO, Cad_coletiva$QUADRO, Desp_coletiva$QUADRO,
                                   Desp_individual$QUADRO, Outros_rend$QUADRO, Rend$QUADRO),
                      "V9001" = as.numeric(c(Aluguel$V9001, Cad_coletiva$V9001, Desp_coletiva$V9001,
                                             Desp_individual$V9001, Outros_rend$V9001, Rend$V9001)),
                      "V9011" = c(Aluguel$V9011, sample(NA, 789995, replace = T), Desp_coletiva$V9011, 
                                  Desp_individual$V9011, Outros_rend$V9011, Rend$V9011),
                      "V8000_DEF" = c(Aluguel$V8000_DEFLA, Cad_coletiva$V8000_DEFLA, 
                                      Desp_coletiva$V8000_DEFLA, Desp_individual$V8000_DEFLA, 
                                      sample(NA, 206108, replace = T), sample(NA, 97075, replace = T)),
                      "ANUALIZADOR" = c(Aluguel$FATOR_ANUALIZACAO, Cad_coletiva$FATOR_ANUALIZACAO, 
                                        Desp_coletiva$FATOR_ANUALIZACAO, Desp_individual$FATOR_ANUALIZACAO, 
                                        Outros_rend$FATOR_ANUALIZACAO, Rend$FATOR_ANUALIZACAO),
                      "PESO_FINAL" = c(Aluguel$PESO_FINAL, Cad_coletiva$PESO_FINAL, 
                                       Desp_coletiva$PESO_FINAL, Desp_individual$PESO_FINAL, 
                                       Outros_rend$PESO_FINAL, Rend$PESO_FINAL),
                      "V1904_DEF" = c(sample(NA, 48935, replace = T), sample(NA, 789995, replace = T),
                                      Desp_coletiva$V1904_DEFLA, sample(NA, 1836032, replace = T),
                                      sample(NA, 206108, replace = T), sample(NA, 97075, replace = T)),
                      "V8501_DEF" = c(sample(NA, 48935, replace = T), sample(NA, 789995, replace = T),
                                      sample(NA, 478572, replace = T), sample(NA, 1836032, replace = T),
                                      Outros_rend$V8501_DEFLA, sample(NA, 97075, replace = T)),
                      "V531112_DEF" = c(sample(NA, 48935, replace = T), sample(NA, 789995, replace = T),
                                        sample(NA, 478572, replace = T), sample(NA, 1836032, replace = T),
                                        sample(NA, 206108, replace = T), Rend$V531112_DEFLA),
                      "V531122_DEF" = c(sample(NA, 48935, replace = T), sample(NA, 789995, replace = T),
                                        sample(NA, 478572, replace = T), sample(NA, 1836032, replace = T),
                                        sample(NA, 206108, replace = T), Rend$V531122_DEFLA),
                      "V531132_DEF" = c(sample(NA, 48935, replace = T), sample(NA, 789995, replace = T),
                                        sample(NA, 478572, replace = T), sample(NA, 1836032, replace = T),
                                        sample(NA, 206108, replace = T), Rend$V531132_DEFLA)) %>% 
  mutate("NUM_DOM" = str_pad(NUM_DOM, 2, "left", "0"),
         "NUM_UC" = str_pad(NUM_UC, 2, "left", "0"),
         "ID_DOM" = str_c(COD_UPA, NUM_DOM),
         "ID_UC"  = str_c(COD_UPA, NUM_DOM, NUM_UC),
         "PESO_FINAL" = as.numeric(PESO_FINAL),
         "DESP_A" = case_when(QUADRO == 0 | QUADRO == 10 | QUADRO == 19 | QUADRO == 44 | QUADRO == 47 | QUADRO == 48 | QUADRO == 49 | QUADRO == 50 ~ round(V8000_DEF * V9011 * ANUALIZADOR * PESO_FINAL, digits = 2),
                              QUADRO %in% c(63:69) | QUADRO %in% c(6:9) | QUADRO %in% c(11:18) | QUADRO %in% c(21:43) | QUADRO == 45 | QUADRO == 46 | QUADRO == 51 ~ round(V8000_DEF * ANUALIZADOR * PESO_FINAL, digits = 2),
                              TRUE ~ NA),
         "INSS_A" = case_when(QUADRO %in% c(6:19) ~ round(V1904_DEF * V9011 * ANUALIZADOR * PESO_FINAL, digits = 2),
                             TRUE ~ NA),
         "CPP_A" = case_when(QUADRO == 53 ~ round(V531112_DEF * V9011 * ANUALIZADOR * PESO_FINAL, digits = 2),
                             TRUE ~ NA),
         "IRPF_A" = case_when(QUADRO == 53 ~ round(V531122_DEF * V9011 * ANUALIZADOR * PESO_FINAL, digits = 2),
                             TRUE ~ NA),
         "ISSQN_A" = case_when(QUADRO == 53 ~ round(V531132_DEF * V9011 * ANUALIZADOR * PESO_FINAL, digits = 2),
                             TRUE ~ NA),
         "DEDUCOES_A" = case_when(QUADRO == 54 ~ round(V8501_DEF * V9011 * ANUALIZADOR * PESO_FINAL, digits = 2),
                                QUADRO %in% c(55:57) ~ round(V8501_DEF * ANUALIZADOR * PESO_FINAL, digits = 2),
                                TRUE ~ NA),
         "PROD_5D" = round(V9001 / 100))

rm(Aluguel, Cad_coletiva, Desp_coletiva, Desp_individual, Outros_rend, Rend)

### Relacionamento do tradutor de POF-SCN com as despesas por produtos (3.3)

tradutor_pof_scn <-
  readxl::read_excel("...") %>% 
  mutate(`CÓDIGO POF1718` = as.integer(`CÓDIGO POF1718`))

Despesas = left_join(Despesas, tradutor_pof_scn, by = c("V9001" = "CÓDIGO POF1718"))

rm(tradutor_pof_scn)

### Geracao da base para resultados (3.4)

base_trab = Despesas %>% 
  mutate("DESP_A2" = tibble(INSS_A, CPP_A, IRPF_A, ISSQN_A, DESP_A, DEDUCOES_A) %>% 
           rowSums(na.rm = T)) %>% 
  group_by(UF, ID_UC, COD_SCN_18SET, SCN_18SET) %>%
  summarise("DESP_F" = sum(DESP_A2)) %>%
  filter(!is.na(COD_SCN_18SET))

### Ajuste no caderno morador para geracao de resultados (3.5)
# Leitura do arquivo de pos-estratificacao para geracao de resultados populacionais

pos_estrat = read_excel(file.path(tempdir(), "Pos_estratos_totais.xlsx"), skip = 5) %>%
  data.frame()

names(pos_estrat) = c("ESTRATO_POF", "POS_ESTRATO", "PESSOAS_T", "UF", "COD_UPA")

# Criacao de chaves de indentificacao de domicilios e pessoas - ID_DOM; ID_UC
# Identificacao de moradores da unidade de consumo - Familiares
# Contagem da pessoas que compartilham a despesa - Num_morador
# Calculo da Renda Familiar Bruta Per Capita - RFBPC

Morador = Morador %>% 
  mutate("NUM_DOM" = str_pad(NUM_DOM, 2, "left", "0"),
         "NUM_UC" = str_pad(NUM_UC, 2, "left", "0"),
         "COD_INFORMANTE" = str_pad(COD_INFORMANTE, 2, "left", "0"),
         "ID_DOM" = str_c(COD_UPA, NUM_DOM),
         "ID_UC"  = str_c(COD_UPA, NUM_DOM, NUM_UC),
         "ID_PES" = str_c(COD_UPA, NUM_DOM, NUM_UC, COD_INFORMANTE),
         "PESO" = as.numeric(PESO),
         "PESO_FINAL" = as.numeric(PESO_FINAL),
         "Pessoas" = 1,
         "Familiares" = ifelse(V0306 %in% c(1:17), 1, 0)) %>%
  group_by(ID_UC) %>%
  mutate("Num_morador" = sum(Familiares),
         "RFBPC" = round(RENDA_TOTAL / Num_morador))

# Preparando microdados morador para pos-estratificacao

Morador = left_join(Morador, pos_estrat, "COD_UPA")

### Definicao da amostra da compexa para microdados de moradores (3.6)

options(survey.lonely.psu = "adjust")

Morador_cpx = svydesign(id = ~ COD_UPA,
                        strata = ~ ESTRATO_POF.x,
                        weights = ~ PESO,
                        data = Morador,
                        nest = T)

Pop_total = aggregate(PESO_FINAL ~ POS_ESTRATO, Morador, sum)

Morador_design = postStratify(Morador_cpx, ~POS_ESTRATO, Pop_total)

rm(Morador_cpx, Pop_total, pos_estrat)


###+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
### GERACAO DE RESULTADOS (4)
###+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

### criacao de decimos da RFBPC por estados (4.1)
# Gerar decis para o Brasil não garante os decimos por estado, mas o inverso e verdadeiro

UF_decis = svyby(~RFBPC, ~UF.x, Morador_design, FUN = svyquantile,
                 quantiles = seq(0, 1, .1))

UF_decis = UF_decis[ , c(1, 3:11)]

# Atualizando a amostra complexa pela classificaco de decis da RFBPC

Morador_design = update(Morador_design,
                        "D_RFBPC" = case_when(UF.x == 12 & RFBPC < 231 ~ "D01",
                                              UF.x == 12 & RFBPC >= 231 & RFBPC < 330 ~ "D02",
                                              UF.x == 12 & RFBPC >= 330 & RFBPC < 442 ~ "D03",
                                              UF.x == 12 & RFBPC >= 442 & RFBPC < 512 ~ "D04",
                                              UF.x == 12 & RFBPC >= 512 & RFBPC < 644 ~ "D05",
                                              UF.x == 12 & RFBPC >= 644 & RFBPC < 805 ~ "D06",
                                              UF.x == 12 & RFBPC >= 805 & RFBPC < 1029 ~ "D07",
                                              UF.x == 12 & RFBPC >= 1029 & RFBPC < 1350 ~ "D08",
                                              UF.x == 12 & RFBPC >= 1350 & RFBPC < 2179 ~ "D09",
                                              UF.x == 12 & RFBPC >= 2179 ~ "D10",
                                              UF.x == 27 & RFBPC < 174 ~ "D01",
                                              UF.x == 27 & RFBPC >= 174 & RFBPC < 247 ~ "D02",
                                              UF.x == 27 & RFBPC >= 247 & RFBPC < 342 ~ "D03",
                                              UF.x == 27 & RFBPC >= 342 & RFBPC < 421 ~ "D04",
                                              UF.x == 27 & RFBPC >= 421 & RFBPC < 523 ~ "D05",
                                              UF.x == 27 & RFBPC >= 523 & RFBPC < 677 ~ "D06",
                                              UF.x == 27 & RFBPC >= 677 & RFBPC < 827 ~ "D07",
                                              UF.x == 27 & RFBPC >= 827 & RFBPC < 1165 ~ "D08",
                                              UF.x == 27 & RFBPC >= 1165 & RFBPC < 1742 ~ "D09",
                                              UF.x == 27 & RFBPC >= 1742 ~ "D10",
                                              UF.x == 16 & RFBPC < 262 ~ "D01",
                                              UF.x == 16 & RFBPC >= 262 & RFBPC < 378 ~ "D02",
                                              UF.x == 16 & RFBPC >= 378 & RFBPC < 448 ~ "D03",
                                              UF.x == 16 & RFBPC >= 448 & RFBPC < 571 ~ "D04",
                                              UF.x == 16 & RFBPC >= 571 & RFBPC < 688 ~ "D05",
                                              UF.x == 16 & RFBPC >= 688 & RFBPC < 897 ~ "D06",
                                              UF.x == 16 & RFBPC >= 897 & RFBPC < 1195 ~ "D07",
                                              UF.x == 16 & RFBPC >= 1195 & RFBPC < 1597 ~ "D08",
                                              UF.x == 16 & RFBPC >= 1597 & RFBPC < 2489 ~ "D09",
                                              UF.x == 16 & RFBPC >= 2489 ~ "D10",
                                              UF.x == 13 & RFBPC < 164 ~ "D01",
                                              UF.x == 13 & RFBPC >= 164 & RFBPC < 251 ~ "D02",
                                              UF.x == 13 & RFBPC >= 251 & RFBPC < 348 ~ "D03",
                                              UF.x == 13 & RFBPC >= 348 & RFBPC < 451 ~ "D04",
                                              UF.x == 13 & RFBPC >= 451 & RFBPC < 577 ~ "D05",
                                              UF.x == 13 & RFBPC >= 577 & RFBPC < 711 ~ "D06",
                                              UF.x == 13 & RFBPC >= 711 & RFBPC < 902 ~ "D07",
                                              UF.x == 13 & RFBPC >= 902 & RFBPC < 1250 ~ "D08",
                                              UF.x == 13 & RFBPC >= 1250 & RFBPC < 2153 ~ "D09",
                                              UF.x == 13 & RFBPC >= 2153 ~ "D10",
                                              UF.x == 29 & RFBPC < 250 ~ "D01",
                                              UF.x == 29 & RFBPC >= 250 & RFBPC < 362 ~ "D02",
                                              UF.x == 29 & RFBPC >= 362 & RFBPC < 482 ~ "D03",
                                              UF.x == 29 & RFBPC >= 482 & RFBPC < 607 ~ "D04",
                                              UF.x == 29 & RFBPC >= 607 & RFBPC < 755 ~ "D05",
                                              UF.x == 29 & RFBPC >= 755 & RFBPC < 962 ~ "D06",
                                              UF.x == 29 & RFBPC >= 962 & RFBPC < 1191 ~ "D07",
                                              UF.x == 29 & RFBPC >= 1191 & RFBPC < 1553 ~ "D08",
                                              UF.x == 29 & RFBPC >= 1553 & RFBPC < 2400 ~ "D09",
                                              UF.x == 29 & RFBPC >= 2400 ~ "D10",
                                              UF.x == 23 & RFBPC < 201 ~ "D01",
                                              UF.x == 23 & RFBPC >= 201 & RFBPC < 313 ~ "D02",
                                              UF.x == 23 & RFBPC >= 313 & RFBPC < 421 ~ "D03",
                                              UF.x == 23 & RFBPC >= 421 & RFBPC < 545 ~ "D04",
                                              UF.x == 23 & RFBPC >= 545 & RFBPC < 672 ~ "D05",
                                              UF.x == 23 & RFBPC >= 672 & RFBPC < 821 ~ "D06",
                                              UF.x == 23 & RFBPC >= 821 & RFBPC < 1042 ~ "D07",
                                              UF.x == 23 & RFBPC >= 1042 & RFBPC < 1311 ~ "D08",
                                              UF.x == 23 & RFBPC >= 1311 & RFBPC < 1958 ~ "D09",
                                              UF.x == 23 & RFBPC >= 1958 ~ "D10",
                                              UF.x == 53 & RFBPC < 548 ~ "D01",
                                              UF.x == 53 & RFBPC >= 548 & RFBPC < 808 ~ "D02",
                                              UF.x == 53 & RFBPC >= 808 & RFBPC < 1110 ~ "D03",
                                              UF.x == 53 & RFBPC >= 1110 & RFBPC < 1466 ~ "D04",
                                              UF.x == 53 & RFBPC >= 1466 & RFBPC < 1907 ~ "D05",
                                              UF.x == 53 & RFBPC >= 1907 & RFBPC < 2427 ~ "D06",
                                              UF.x == 53 & RFBPC >= 2427 & RFBPC < 3323 ~ "D07",
                                              UF.x == 53 & RFBPC >= 3323 & RFBPC < 5403 ~ "D08",
                                              UF.x == 53 & RFBPC >= 5403 & RFBPC < 10350~ "D09",
                                              UF.x == 53 & RFBPC >= 10350 ~ "D10",
                                              UF.x == 32 & RFBPC < 381 ~ "D01",
                                              UF.x == 32 & RFBPC >= 381 & RFBPC < 555 ~ "D02",
                                              UF.x == 32 & RFBPC >= 555 & RFBPC < 724 ~ "D03",
                                              UF.x == 32 & RFBPC >= 724 & RFBPC < 918 ~ "D04",
                                              UF.x == 32 & RFBPC >= 918 & RFBPC < 1114 ~ "D05",
                                              UF.x == 32 & RFBPC >= 1114 & RFBPC < 1367 ~ "D06",
                                              UF.x == 32 & RFBPC >= 1367 & RFBPC < 1662 ~ "D07",
                                              UF.x == 32 & RFBPC >= 1662 & RFBPC < 2200 ~ "D08",
                                              UF.x == 32 & RFBPC >= 2200 & RFBPC < 3398 ~ "D09",
                                              UF.x == 32 & RFBPC >= 3398 ~ "D10",
                                              UF.x == 52 & RFBPC < 454 ~ "D01",
                                              UF.x == 52 & RFBPC >= 454 & RFBPC < 637 ~ "D02",
                                              UF.x == 52 & RFBPC >= 637 & RFBPC < 800 ~ "D03",
                                              UF.x == 52 & RFBPC >= 800 & RFBPC < 989 ~ "D04",
                                              UF.x == 52 & RFBPC >= 989 & RFBPC < 1194 ~ "D05",
                                              UF.x == 52 & RFBPC >= 1194 & RFBPC < 1445 ~ "D06",
                                              UF.x == 52 & RFBPC >= 1445 & RFBPC < 1730 ~ "D07",
                                              UF.x == 52 & RFBPC >= 1730 & RFBPC < 2257 ~ "D08",
                                              UF.x == 52 & RFBPC >= 2257 & RFBPC < 3614 ~ "D09",
                                              UF.x == 52 & RFBPC >= 3614 ~ "D10",
                                              UF.x == 21 & RFBPC < 171 ~ "D01",
                                              UF.x == 21 & RFBPC >= 171 & RFBPC < 256 ~ "D02",
                                              UF.x == 21 & RFBPC >= 256 & RFBPC < 346 ~ "D03",
                                              UF.x == 21 & RFBPC >= 346 & RFBPC < 439 ~ "D04",
                                              UF.x == 21 & RFBPC >= 439 & RFBPC < 558 ~ "D05",
                                              UF.x == 21 & RFBPC >= 558 & RFBPC < 677 ~ "D06",
                                              UF.x == 21 & RFBPC >= 677 & RFBPC < 827 ~ "D07",
                                              UF.x == 21 & RFBPC >= 827 & RFBPC < 1085 ~ "D08",
                                              UF.x == 21 & RFBPC >= 1085 & RFBPC < 1533 ~ "D09",
                                              UF.x == 21 & RFBPC >= 1533 ~ "D10",
                                              UF.x == 51 & RFBPC < 402 ~ "D01",
                                              UF.x == 51 & RFBPC >= 402 & RFBPC < 591 ~ "D02",
                                              UF.x == 51 & RFBPC >= 591 & RFBPC < 797 ~ "D03",
                                              UF.x == 51 & RFBPC >= 797 & RFBPC < 957 ~ "D04",
                                              UF.x == 51 & RFBPC >= 957 & RFBPC < 1182 ~ "D05",
                                              UF.x == 51 & RFBPC >= 1182 & RFBPC < 1427 ~ "D06",
                                              UF.x == 51 & RFBPC >= 1427 & RFBPC < 1711 ~ "D07",
                                              UF.x == 51 & RFBPC >= 1711 & RFBPC < 2226 ~ "D08",
                                              UF.x == 51 & RFBPC >= 2226 & RFBPC < 3626 ~ "D09",
                                              UF.x == 51 & RFBPC >= 3626 ~ "D10",
                                              UF.x == 50 & RFBPC < 486 ~ "D01",
                                              UF.x == 50 & RFBPC >= 486 & RFBPC < 660 ~ "D02",
                                              UF.x == 50 & RFBPC >= 660 & RFBPC < 881 ~ "D03",
                                              UF.x == 50 & RFBPC >= 881 & RFBPC < 1053 ~ "D04",
                                              UF.x == 50 & RFBPC >= 1053 & RFBPC < 1287 ~ "D05",
                                              UF.x == 50 & RFBPC >= 1287 & RFBPC < 1564 ~ "D06",
                                              UF.x == 50 & RFBPC >= 1564 & RFBPC < 1923 ~ "D07",
                                              UF.x == 50 & RFBPC >= 1923 & RFBPC < 2450 ~ "D08",
                                              UF.x == 50 & RFBPC >= 2450 & RFBPC < 3641 ~ "D09",
                                              UF.x == 50 & RFBPC >= 3641 ~ "D10",
                                              UF.x == 31 & RFBPC < 441 ~ "D01",
                                              UF.x == 31 & RFBPC >= 441 & RFBPC < 634 ~ "D02",
                                              UF.x == 31 & RFBPC >= 634 & RFBPC < 794 ~ "D03",
                                              UF.x == 31 & RFBPC >= 794 & RFBPC < 963 ~ "D04",
                                              UF.x == 31 & RFBPC >= 963 & RFBPC < 1161 ~ "D05",
                                              UF.x == 31 & RFBPC >= 1161 & RFBPC < 1367 ~ "D06",
                                              UF.x == 31 & RFBPC >= 1367 & RFBPC < 1656 ~ "D07",
                                              UF.x == 31 & RFBPC >= 1656 & RFBPC < 2086 ~ "D08",
                                              UF.x == 31 & RFBPC >= 2086 & RFBPC < 3223 ~ "D09",
                                              UF.x == 31 & RFBPC >= 3223 ~ "D10",
                                              UF.x == 15 & RFBPC < 181 ~ "D01",
                                              UF.x == 15 & RFBPC >= 181 & RFBPC < 264 ~ "D02",
                                              UF.x == 15 & RFBPC >= 264 & RFBPC < 366 ~ "D03",
                                              UF.x == 15 & RFBPC >= 366 & RFBPC < 476 ~ "D04",
                                              UF.x == 15 & RFBPC >= 476 & RFBPC < 608 ~ "D05",
                                              UF.x == 15 & RFBPC >= 608 & RFBPC < 741 ~ "D06",
                                              UF.x == 15 & RFBPC >= 741 & RFBPC < 956 ~ "D07",
                                              UF.x == 15 & RFBPC >= 956 & RFBPC < 1211 ~ "D08",
                                              UF.x == 15 & RFBPC >= 1211 & RFBPC < 1900 ~ "D09",
                                              UF.x == 15 & RFBPC >= 1900 ~ "D10",
                                              UF.x == 25 & RFBPC < 185 ~ "D01",
                                              UF.x == 25 & RFBPC >= 185 & RFBPC < 296 ~ "D02",
                                              UF.x == 25 & RFBPC >= 296 & RFBPC < 401 ~ "D03",
                                              UF.x == 25 & RFBPC >= 401 & RFBPC < 512 ~ "D04",
                                              UF.x == 25 & RFBPC >= 512 & RFBPC < 670 ~ "D05",
                                              UF.x == 25 & RFBPC >= 670 & RFBPC < 838 ~ "D06",
                                              UF.x == 25 & RFBPC >= 838 & RFBPC < 1090 ~ "D07",
                                              UF.x == 25 & RFBPC >= 1090 & RFBPC < 1416 ~ "D08",
                                              UF.x == 25 & RFBPC >= 1416 & RFBPC < 2052 ~ "D09",
                                              UF.x == 25 & RFBPC >= 2052 ~ "D10",
                                              UF.x == 41 & RFBPC < 441 ~ "D01",
                                              UF.x == 41 & RFBPC >= 441 & RFBPC < 659 ~ "D02",
                                              UF.x == 41 & RFBPC >= 659 & RFBPC < 858 ~ "D03",
                                              UF.x == 41 & RFBPC >= 858 & RFBPC < 1073 ~ "D04",
                                              UF.x == 41 & RFBPC >= 1073 & RFBPC < 1317 ~ "D05",
                                              UF.x == 41 & RFBPC >= 1317 & RFBPC < 1571 ~ "D06",
                                              UF.x == 41 & RFBPC >= 1571 & RFBPC < 2002 ~ "D07",
                                              UF.x == 41 & RFBPC >= 2002 & RFBPC < 2592 ~ "D08",
                                              UF.x == 41 & RFBPC >= 2592 & RFBPC < 3992 ~ "D09",
                                              UF.x == 41 & RFBPC >= 3992 ~ "D10",
                                              UF.x == 26 & RFBPC < 233 ~ "D01",
                                              UF.x == 26 & RFBPC >= 233 & RFBPC < 362 ~ "D02",
                                              UF.x == 26 & RFBPC >= 362 & RFBPC < 480 ~ "D03",
                                              UF.x == 26 & RFBPC >= 480 & RFBPC < 605 ~ "D04",
                                              UF.x == 26 & RFBPC >= 605 & RFBPC < 757 ~ "D05",
                                              UF.x == 26 & RFBPC >= 757 & RFBPC < 935 ~ "D06",
                                              UF.x == 26 & RFBPC >= 935 & RFBPC < 1159 ~ "D07",
                                              UF.x == 26 & RFBPC >= 1159 & RFBPC < 1524 ~ "D08",
                                              UF.x == 26 & RFBPC >= 1524 & RFBPC < 2509 ~ "D09",
                                              UF.x == 26 & RFBPC >= 2509 ~ "D10",
                                              UF.x == 22 & RFBPC < 261 ~ "D01",
                                              UF.x == 22 & RFBPC >= 261 & RFBPC < 367 ~ "D02",
                                              UF.x == 22 & RFBPC >= 367 & RFBPC < 474 ~ "D03",
                                              UF.x == 22 & RFBPC >= 474 & RFBPC < 577 ~ "D04",
                                              UF.x == 22 & RFBPC >= 577 & RFBPC < 709 ~ "D05",
                                              UF.x == 22 & RFBPC >= 709 & RFBPC < 863 ~ "D06",
                                              UF.x == 22 & RFBPC >= 863 & RFBPC < 1040 ~ "D07",
                                              UF.x == 22 & RFBPC >= 1040 & RFBPC < 1332 ~ "D08",
                                              UF.x == 22 & RFBPC >= 1332 & RFBPC < 2135 ~ "D09",
                                              UF.x == 22 & RFBPC >= 2135 ~ "D10",
                                              UF.x == 33 & RFBPC < 353 ~ "D01",
                                              UF.x == 33 & RFBPC >= 353 & RFBPC < 555 ~ "D02",
                                              UF.x == 33 & RFBPC >= 555 & RFBPC < 740 ~ "D03",
                                              UF.x == 33 & RFBPC >= 740 & RFBPC < 911 ~ "D04",
                                              UF.x == 33 & RFBPC >= 911 & RFBPC < 1142 ~ "D05",
                                              UF.x == 33 & RFBPC >= 1142 & RFBPC < 1416 ~ "D06",
                                              UF.x == 33 & RFBPC >= 1416 & RFBPC < 1774 ~ "D07",
                                              UF.x == 33 & RFBPC >= 1774 & RFBPC < 2562 ~ "D08",
                                              UF.x == 33 & RFBPC >= 2562 & RFBPC < 4095 ~ "D09",
                                              UF.x == 33 & RFBPC >= 4095 ~ "D10",
                                              UF.x == 24 & RFBPC < 297 ~ "D01",
                                              UF.x == 24 & RFBPC >= 297 & RFBPC < 405 ~ "D02",
                                              UF.x == 24 & RFBPC >= 405 & RFBPC < 512 ~ "D03",
                                              UF.x == 24 & RFBPC >= 512 & RFBPC < 658 ~ "D04",
                                              UF.x == 24 & RFBPC >= 658 & RFBPC < 820 ~ "D05",
                                              UF.x == 24 & RFBPC >= 820 & RFBPC < 1019 ~ "D06",
                                              UF.x == 24 & RFBPC >= 1019 & RFBPC < 1237 ~ "D07",
                                              UF.x == 24 & RFBPC >= 1237 & RFBPC < 1611 ~ "D08",
                                              UF.x == 24 & RFBPC >= 1611 & RFBPC < 2371 ~ "D09",
                                              UF.x == 24 & RFBPC >= 2371 ~ "D10",
                                              UF.x == 43 & RFBPC < 549 ~ "D01",
                                              UF.x == 43 & RFBPC >= 549 & RFBPC < 814 ~ "D02",
                                              UF.x == 43 & RFBPC >= 814 & RFBPC < 1070 ~ "D03",
                                              UF.x == 43 & RFBPC >= 1070 & RFBPC < 1315 ~ "D04",
                                              UF.x == 43 & RFBPC >= 1315 & RFBPC < 1572 ~ "D05",
                                              UF.x == 43 & RFBPC >= 1572 & RFBPC < 1879 ~ "D06",
                                              UF.x == 43 & RFBPC >= 1879 & RFBPC < 2289 ~ "D07",
                                              UF.x == 43 & RFBPC >= 2289 & RFBPC < 3010 ~ "D08",
                                              UF.x == 43 & RFBPC >= 3010 & RFBPC < 4328 ~ "D09",
                                              UF.x == 43 & RFBPC >= 4328 ~ "D10",
                                              UF.x == 11 & RFBPC < 326 ~ "D01",
                                              UF.x == 11 & RFBPC >= 326 & RFBPC < 489 ~ "D02",
                                              UF.x == 11 & RFBPC >= 489 & RFBPC < 617 ~ "D03",
                                              UF.x == 11 & RFBPC >= 617 & RFBPC < 736 ~ "D04",
                                              UF.x == 11 & RFBPC >= 736 & RFBPC < 896 ~ "D05",
                                              UF.x == 11 & RFBPC >= 896 & RFBPC < 1061 ~ "D06",
                                              UF.x == 11 & RFBPC >= 1061 & RFBPC < 1335 ~ "D07",
                                              UF.x == 11 & RFBPC >= 1335 & RFBPC < 1680 ~ "D08",
                                              UF.x == 11 & RFBPC >= 1680 & RFBPC < 2496 ~ "D09",
                                              UF.x == 11 & RFBPC >= 2496 ~ "D10",
                                              UF.x == 14 & RFBPC < 220 ~ "D01",
                                              UF.x == 14 & RFBPC >= 220 & RFBPC < 320 ~ "D02",
                                              UF.x == 14 & RFBPC >= 320 & RFBPC < 429 ~ "D03",
                                              UF.x == 14 & RFBPC >= 429 & RFBPC < 558 ~ "D04",
                                              UF.x == 14 & RFBPC >= 558 & RFBPC < 758 ~ "D05",
                                              UF.x == 14 & RFBPC >= 758 & RFBPC < 987 ~ "D06",
                                              UF.x == 14 & RFBPC >= 987 & RFBPC < 1214 ~ "D07",
                                              UF.x == 14 & RFBPC >= 1214 & RFBPC < 1754 ~ "D08",
                                              UF.x == 14 & RFBPC >= 1754 & RFBPC < 2658 ~ "D09",
                                              UF.x == 14 & RFBPC >= 2658 ~ "D10",
                                              UF.x == 42 & RFBPC < 591 ~ "D01",
                                              UF.x == 42 & RFBPC >= 591 & RFBPC < 843 ~ "D02",
                                              UF.x == 42 & RFBPC >= 843 & RFBPC < 1084 ~ "D03",
                                              UF.x == 42 & RFBPC >= 1084 & RFBPC < 1322 ~ "D04",
                                              UF.x == 42 & RFBPC >= 1322 & RFBPC < 1548 ~ "D05",
                                              UF.x == 42 & RFBPC >= 1548 & RFBPC < 1838 ~ "D06",
                                              UF.x == 42 & RFBPC >= 1838 & RFBPC < 2261 ~ "D07",
                                              UF.x == 42 & RFBPC >= 2261 & RFBPC < 2833 ~ "D08",
                                              UF.x == 42 & RFBPC >= 2833 & RFBPC < 4106 ~ "D09",
                                              UF.x == 42 & RFBPC >= 4106 ~ "D10",
                                              UF.x == 35 & RFBPC < 515 ~ "D01",
                                              UF.x == 35 & RFBPC >= 515 & RFBPC < 763 ~ "D02",
                                              UF.x == 35 & RFBPC >= 763 & RFBPC < 986 ~ "D03",
                                              UF.x == 35 & RFBPC >= 986 & RFBPC < 1204 ~ "D04",
                                              UF.x == 35 & RFBPC >= 1204 & RFBPC < 1475 ~ "D05",
                                              UF.x == 35 & RFBPC >= 1475 & RFBPC < 1798 ~ "D06",
                                              UF.x == 35 & RFBPC >= 1798 & RFBPC < 2274 ~ "D07",
                                              UF.x == 35 & RFBPC >= 2274 & RFBPC < 3142 ~ "D08",
                                              UF.x == 35 & RFBPC >= 3142 & RFBPC < 5155 ~ "D09",
                                              UF.x == 35 & RFBPC >= 5155 ~ "D10",
                                              UF.x == 28 & RFBPC < 341 ~ "D01",
                                              UF.x == 28 & RFBPC >= 341 & RFBPC < 460 ~ "D02",
                                              UF.x == 28 & RFBPC >= 460 & RFBPC < 576 ~ "D03",
                                              UF.x == 28 & RFBPC >= 576 & RFBPC < 719 ~ "D04",
                                              UF.x == 28 & RFBPC >= 719 & RFBPC < 886 ~ "D05",
                                              UF.x == 28 & RFBPC >= 886 & RFBPC < 1117 ~ "D06",
                                              UF.x == 28 & RFBPC >= 1117 & RFBPC < 1415 ~ "D07",
                                              UF.x == 28 & RFBPC >= 1415 & RFBPC < 1833 ~ "D08",
                                              UF.x == 28 & RFBPC >= 1833 & RFBPC < 3007 ~ "D09",
                                              UF.x == 28 & RFBPC >= 3007 ~ "D10",
                                              UF.x == 17 & RFBPC < 214 ~ "D01",
                                              UF.x == 17 & RFBPC >= 214 & RFBPC < 337 ~ "D02",
                                              UF.x == 17 & RFBPC >= 337 & RFBPC < 445 ~ "D03",
                                              UF.x == 17 & RFBPC >= 445 & RFBPC < 564 ~ "D04",
                                              UF.x == 17 & RFBPC >= 564 & RFBPC < 693 ~ "D05",
                                              UF.x == 17 & RFBPC >= 693 & RFBPC < 794 ~ "D06",
                                              UF.x == 17 & RFBPC >= 794 & RFBPC < 984 ~ "D07",
                                              UF.x == 17 & RFBPC >= 984 & RFBPC < 1234 ~ "D08",
                                              UF.x == 17 & RFBPC >= 1234 & RFBPC < 1976 ~ "D09",
                                              UF.x == 17 & RFBPC >= 1976 ~ "D10"),
                        'Pob_RFBPC' = case_when(RFBPC <= 422 ~ 1,
                                                TRUE ~ 0),
                        'Hiato_RFBPC' = case_when(RFBPC <= 422 ~ 422 - RFBPC,
                                                  TRUE ~ NA_real_))

rm(UF_decis)

# Atualizando a amostra de base pela classificaco de decis da RFBPC

Morador = mutate(Morador,
                 "D_RFBPC" = case_when(UF.x == 12 & RFBPC < 231 ~ "D01",
                                       UF.x == 12 & RFBPC >= 231 & RFBPC < 330 ~ "D02",
                                       UF.x == 12 & RFBPC >= 330 & RFBPC < 442 ~ "D03",
                                       UF.x == 12 & RFBPC >= 442 & RFBPC < 512 ~ "D04",
                                       UF.x == 12 & RFBPC >= 512 & RFBPC < 644 ~ "D05",
                                       UF.x == 12 & RFBPC >= 644 & RFBPC < 805 ~ "D06",
                                       UF.x == 12 & RFBPC >= 805 & RFBPC < 1029 ~ "D07",
                                       UF.x == 12 & RFBPC >= 1029 & RFBPC < 1350 ~ "D08",
                                       UF.x == 12 & RFBPC >= 1350 & RFBPC < 2179 ~ "D09",
                                       UF.x == 12 & RFBPC >= 2179 ~ "D10",
                                       UF.x == 27 & RFBPC < 174 ~ "D01",
                                       UF.x == 27 & RFBPC >= 174 & RFBPC < 247 ~ "D02",
                                       UF.x == 27 & RFBPC >= 247 & RFBPC < 342 ~ "D03",
                                       UF.x == 27 & RFBPC >= 342 & RFBPC < 421 ~ "D04",
                                       UF.x == 27 & RFBPC >= 421 & RFBPC < 523 ~ "D05",
                                       UF.x == 27 & RFBPC >= 523 & RFBPC < 677 ~ "D06",
                                       UF.x == 27 & RFBPC >= 677 & RFBPC < 827 ~ "D07",
                                       UF.x == 27 & RFBPC >= 827 & RFBPC < 1165 ~ "D08",
                                       UF.x == 27 & RFBPC >= 1165 & RFBPC < 1742 ~ "D09",
                                       UF.x == 27 & RFBPC >= 1742 ~ "D10",
                                       UF.x == 16 & RFBPC < 262 ~ "D01",
                                       UF.x == 16 & RFBPC >= 262 & RFBPC < 378 ~ "D02",
                                       UF.x == 16 & RFBPC >= 378 & RFBPC < 448 ~ "D03",
                                       UF.x == 16 & RFBPC >= 448 & RFBPC < 571 ~ "D04",
                                       UF.x == 16 & RFBPC >= 571 & RFBPC < 688 ~ "D05",
                                       UF.x == 16 & RFBPC >= 688 & RFBPC < 897 ~ "D06",
                                       UF.x == 16 & RFBPC >= 897 & RFBPC < 1195 ~ "D07",
                                       UF.x == 16 & RFBPC >= 1195 & RFBPC < 1597 ~ "D08",
                                       UF.x == 16 & RFBPC >= 1597 & RFBPC < 2489 ~ "D09",
                                       UF.x == 16 & RFBPC >= 2489 ~ "D10",
                                       UF.x == 13 & RFBPC < 164 ~ "D01",
                                       UF.x == 13 & RFBPC >= 164 & RFBPC < 251 ~ "D02",
                                       UF.x == 13 & RFBPC >= 251 & RFBPC < 348 ~ "D03",
                                       UF.x == 13 & RFBPC >= 348 & RFBPC < 451 ~ "D04",
                                       UF.x == 13 & RFBPC >= 451 & RFBPC < 577 ~ "D05",
                                       UF.x == 13 & RFBPC >= 577 & RFBPC < 711 ~ "D06",
                                       UF.x == 13 & RFBPC >= 711 & RFBPC < 902 ~ "D07",
                                       UF.x == 13 & RFBPC >= 902 & RFBPC < 1250 ~ "D08",
                                       UF.x == 13 & RFBPC >= 1250 & RFBPC < 2153 ~ "D09",
                                       UF.x == 13 & RFBPC >= 2153 ~ "D10",
                                       UF.x == 29 & RFBPC < 250 ~ "D01",
                                       UF.x == 29 & RFBPC >= 250 & RFBPC < 362 ~ "D02",
                                       UF.x == 29 & RFBPC >= 362 & RFBPC < 482 ~ "D03",
                                       UF.x == 29 & RFBPC >= 482 & RFBPC < 607 ~ "D04",
                                       UF.x == 29 & RFBPC >= 607 & RFBPC < 755 ~ "D05",
                                       UF.x == 29 & RFBPC >= 755 & RFBPC < 962 ~ "D06",
                                       UF.x == 29 & RFBPC >= 962 & RFBPC < 1191 ~ "D07",
                                       UF.x == 29 & RFBPC >= 1191 & RFBPC < 1553 ~ "D08",
                                       UF.x == 29 & RFBPC >= 1553 & RFBPC < 2400 ~ "D09",
                                       UF.x == 29 & RFBPC >= 2400 ~ "D10",
                                       UF.x == 23 & RFBPC < 201 ~ "D01",
                                       UF.x == 23 & RFBPC >= 201 & RFBPC < 313 ~ "D02",
                                       UF.x == 23 & RFBPC >= 313 & RFBPC < 421 ~ "D03",
                                       UF.x == 23 & RFBPC >= 421 & RFBPC < 545 ~ "D04",
                                       UF.x == 23 & RFBPC >= 545 & RFBPC < 672 ~ "D05",
                                       UF.x == 23 & RFBPC >= 672 & RFBPC < 821 ~ "D06",
                                       UF.x == 23 & RFBPC >= 821 & RFBPC < 1042 ~ "D07",
                                       UF.x == 23 & RFBPC >= 1042 & RFBPC < 1311 ~ "D08",
                                       UF.x == 23 & RFBPC >= 1311 & RFBPC < 1958 ~ "D09",
                                       UF.x == 23 & RFBPC >= 1958 ~ "D10",
                                       UF.x == 53 & RFBPC < 548 ~ "D01",
                                       UF.x == 53 & RFBPC >= 548 & RFBPC < 808 ~ "D02",
                                       UF.x == 53 & RFBPC >= 808 & RFBPC < 1110 ~ "D03",
                                       UF.x == 53 & RFBPC >= 1110 & RFBPC < 1466 ~ "D04",
                                       UF.x == 53 & RFBPC >= 1466 & RFBPC < 1907 ~ "D05",
                                       UF.x == 53 & RFBPC >= 1907 & RFBPC < 2427 ~ "D06",
                                       UF.x == 53 & RFBPC >= 2427 & RFBPC < 3323 ~ "D07",
                                       UF.x == 53 & RFBPC >= 3323 & RFBPC < 5403 ~ "D08",
                                       UF.x == 53 & RFBPC >= 5403 & RFBPC < 10350~ "D09",
                                       UF.x == 53 & RFBPC >= 10350 ~ "D10",
                                       UF.x == 32 & RFBPC < 381 ~ "D01",
                                       UF.x == 32 & RFBPC >= 381 & RFBPC < 555 ~ "D02",
                                       UF.x == 32 & RFBPC >= 555 & RFBPC < 724 ~ "D03",
                                       UF.x == 32 & RFBPC >= 724 & RFBPC < 918 ~ "D04",
                                       UF.x == 32 & RFBPC >= 918 & RFBPC < 1114 ~ "D05",
                                       UF.x == 32 & RFBPC >= 1114 & RFBPC < 1367 ~ "D06",
                                       UF.x == 32 & RFBPC >= 1367 & RFBPC < 1662 ~ "D07",
                                       UF.x == 32 & RFBPC >= 1662 & RFBPC < 2200 ~ "D08",
                                       UF.x == 32 & RFBPC >= 2200 & RFBPC < 3398 ~ "D09",
                                       UF.x == 32 & RFBPC >= 3398 ~ "D10",
                                       UF.x == 52 & RFBPC < 454 ~ "D01",
                                       UF.x == 52 & RFBPC >= 454 & RFBPC < 637 ~ "D02",
                                       UF.x == 52 & RFBPC >= 637 & RFBPC < 800 ~ "D03",
                                       UF.x == 52 & RFBPC >= 800 & RFBPC < 989 ~ "D04",
                                       UF.x == 52 & RFBPC >= 989 & RFBPC < 1194 ~ "D05",
                                       UF.x == 52 & RFBPC >= 1194 & RFBPC < 1445 ~ "D06",
                                       UF.x == 52 & RFBPC >= 1445 & RFBPC < 1730 ~ "D07",
                                       UF.x == 52 & RFBPC >= 1730 & RFBPC < 2257 ~ "D08",
                                       UF.x == 52 & RFBPC >= 2257 & RFBPC < 3614 ~ "D09",
                                       UF.x == 52 & RFBPC >= 3614 ~ "D10",
                                       UF.x == 21 & RFBPC < 171 ~ "D01",
                                       UF.x == 21 & RFBPC >= 171 & RFBPC < 256 ~ "D02",
                                       UF.x == 21 & RFBPC >= 256 & RFBPC < 346 ~ "D03",
                                       UF.x == 21 & RFBPC >= 346 & RFBPC < 439 ~ "D04",
                                       UF.x == 21 & RFBPC >= 439 & RFBPC < 558 ~ "D05",
                                       UF.x == 21 & RFBPC >= 558 & RFBPC < 677 ~ "D06",
                                       UF.x == 21 & RFBPC >= 677 & RFBPC < 827 ~ "D07",
                                       UF.x == 21 & RFBPC >= 827 & RFBPC < 1085 ~ "D08",
                                       UF.x == 21 & RFBPC >= 1085 & RFBPC < 1533 ~ "D09",
                                       UF.x == 21 & RFBPC >= 1533 ~ "D10",
                                       UF.x == 51 & RFBPC < 402 ~ "D01",
                                       UF.x == 51 & RFBPC >= 402 & RFBPC < 591 ~ "D02",
                                       UF.x == 51 & RFBPC >= 591 & RFBPC < 797 ~ "D03",
                                       UF.x == 51 & RFBPC >= 797 & RFBPC < 957 ~ "D04",
                                       UF.x == 51 & RFBPC >= 957 & RFBPC < 1182 ~ "D05",
                                       UF.x == 51 & RFBPC >= 1182 & RFBPC < 1427 ~ "D06",
                                       UF.x == 51 & RFBPC >= 1427 & RFBPC < 1711 ~ "D07",
                                       UF.x == 51 & RFBPC >= 1711 & RFBPC < 2226 ~ "D08",
                                       UF.x == 51 & RFBPC >= 2226 & RFBPC < 3626 ~ "D09",
                                       UF.x == 51 & RFBPC >= 3626 ~ "D10",
                                       UF.x == 50 & RFBPC < 486 ~ "D01",
                                       UF.x == 50 & RFBPC >= 486 & RFBPC < 660 ~ "D02",
                                       UF.x == 50 & RFBPC >= 660 & RFBPC < 881 ~ "D03",
                                       UF.x == 50 & RFBPC >= 881 & RFBPC < 1053 ~ "D04",
                                       UF.x == 50 & RFBPC >= 1053 & RFBPC < 1287 ~ "D05",
                                       UF.x == 50 & RFBPC >= 1287 & RFBPC < 1564 ~ "D06",
                                       UF.x == 50 & RFBPC >= 1564 & RFBPC < 1923 ~ "D07",
                                       UF.x == 50 & RFBPC >= 1923 & RFBPC < 2450 ~ "D08",
                                       UF.x == 50 & RFBPC >= 2450 & RFBPC < 3641 ~ "D09",
                                       UF.x == 50 & RFBPC >= 3641 ~ "D10",
                                       UF.x == 31 & RFBPC < 441 ~ "D01",
                                       UF.x == 31 & RFBPC >= 441 & RFBPC < 634 ~ "D02",
                                       UF.x == 31 & RFBPC >= 634 & RFBPC < 794 ~ "D03",
                                       UF.x == 31 & RFBPC >= 794 & RFBPC < 963 ~ "D04",
                                       UF.x == 31 & RFBPC >= 963 & RFBPC < 1161 ~ "D05",
                                       UF.x == 31 & RFBPC >= 1161 & RFBPC < 1367 ~ "D06",
                                       UF.x == 31 & RFBPC >= 1367 & RFBPC < 1656 ~ "D07",
                                       UF.x == 31 & RFBPC >= 1656 & RFBPC < 2086 ~ "D08",
                                       UF.x == 31 & RFBPC >= 2086 & RFBPC < 3223 ~ "D09",
                                       UF.x == 31 & RFBPC >= 3223 ~ "D10",
                                       UF.x == 15 & RFBPC < 181 ~ "D01",
                                       UF.x == 15 & RFBPC >= 181 & RFBPC < 264 ~ "D02",
                                       UF.x == 15 & RFBPC >= 264 & RFBPC < 366 ~ "D03",
                                       UF.x == 15 & RFBPC >= 366 & RFBPC < 476 ~ "D04",
                                       UF.x == 15 & RFBPC >= 476 & RFBPC < 608 ~ "D05",
                                       UF.x == 15 & RFBPC >= 608 & RFBPC < 741 ~ "D06",
                                       UF.x == 15 & RFBPC >= 741 & RFBPC < 956 ~ "D07",
                                       UF.x == 15 & RFBPC >= 956 & RFBPC < 1211 ~ "D08",
                                       UF.x == 15 & RFBPC >= 1211 & RFBPC < 1900 ~ "D09",
                                       UF.x == 15 & RFBPC >= 1900 ~ "D10",
                                       UF.x == 25 & RFBPC < 185 ~ "D01",
                                       UF.x == 25 & RFBPC >= 185 & RFBPC < 296 ~ "D02",
                                       UF.x == 25 & RFBPC >= 296 & RFBPC < 401 ~ "D03",
                                       UF.x == 25 & RFBPC >= 401 & RFBPC < 512 ~ "D04",
                                       UF.x == 25 & RFBPC >= 512 & RFBPC < 670 ~ "D05",
                                       UF.x == 25 & RFBPC >= 670 & RFBPC < 838 ~ "D06",
                                       UF.x == 25 & RFBPC >= 838 & RFBPC < 1090 ~ "D07",
                                       UF.x == 25 & RFBPC >= 1090 & RFBPC < 1416 ~ "D08",
                                       UF.x == 25 & RFBPC >= 1416 & RFBPC < 2052 ~ "D09",
                                       UF.x == 25 & RFBPC >= 2052 ~ "D10",
                                       UF.x == 41 & RFBPC < 441 ~ "D01",
                                       UF.x == 41 & RFBPC >= 441 & RFBPC < 659 ~ "D02",
                                       UF.x == 41 & RFBPC >= 659 & RFBPC < 858 ~ "D03",
                                       UF.x == 41 & RFBPC >= 858 & RFBPC < 1073 ~ "D04",
                                       UF.x == 41 & RFBPC >= 1073 & RFBPC < 1317 ~ "D05",
                                       UF.x == 41 & RFBPC >= 1317 & RFBPC < 1571 ~ "D06",
                                       UF.x == 41 & RFBPC >= 1571 & RFBPC < 2002 ~ "D07",
                                       UF.x == 41 & RFBPC >= 2002 & RFBPC < 2592 ~ "D08",
                                       UF.x == 41 & RFBPC >= 2592 & RFBPC < 3992 ~ "D09",
                                       UF.x == 41 & RFBPC >= 3992 ~ "D10",
                                       UF.x == 26 & RFBPC < 233 ~ "D01",
                                       UF.x == 26 & RFBPC >= 233 & RFBPC < 362 ~ "D02",
                                       UF.x == 26 & RFBPC >= 362 & RFBPC < 480 ~ "D03",
                                       UF.x == 26 & RFBPC >= 480 & RFBPC < 605 ~ "D04",
                                       UF.x == 26 & RFBPC >= 605 & RFBPC < 757 ~ "D05",
                                       UF.x == 26 & RFBPC >= 757 & RFBPC < 935 ~ "D06",
                                       UF.x == 26 & RFBPC >= 935 & RFBPC < 1159 ~ "D07",
                                       UF.x == 26 & RFBPC >= 1159 & RFBPC < 1524 ~ "D08",
                                       UF.x == 26 & RFBPC >= 1524 & RFBPC < 2509 ~ "D09",
                                       UF.x == 26 & RFBPC >= 2509 ~ "D10",
                                       UF.x == 22 & RFBPC < 261 ~ "D01",
                                       UF.x == 22 & RFBPC >= 261 & RFBPC < 367 ~ "D02",
                                       UF.x == 22 & RFBPC >= 367 & RFBPC < 474 ~ "D03",
                                       UF.x == 22 & RFBPC >= 474 & RFBPC < 577 ~ "D04",
                                       UF.x == 22 & RFBPC >= 577 & RFBPC < 709 ~ "D05",
                                       UF.x == 22 & RFBPC >= 709 & RFBPC < 863 ~ "D06",
                                       UF.x == 22 & RFBPC >= 863 & RFBPC < 1040 ~ "D07",
                                       UF.x == 22 & RFBPC >= 1040 & RFBPC < 1332 ~ "D08",
                                       UF.x == 22 & RFBPC >= 1332 & RFBPC < 2135 ~ "D09",
                                       UF.x == 22 & RFBPC >= 2135 ~ "D10",
                                       UF.x == 33 & RFBPC < 353 ~ "D01",
                                       UF.x == 33 & RFBPC >= 353 & RFBPC < 555 ~ "D02",
                                       UF.x == 33 & RFBPC >= 555 & RFBPC < 740 ~ "D03",
                                       UF.x == 33 & RFBPC >= 740 & RFBPC < 911 ~ "D04",
                                       UF.x == 33 & RFBPC >= 911 & RFBPC < 1142 ~ "D05",
                                       UF.x == 33 & RFBPC >= 1142 & RFBPC < 1416 ~ "D06",
                                       UF.x == 33 & RFBPC >= 1416 & RFBPC < 1774 ~ "D07",
                                       UF.x == 33 & RFBPC >= 1774 & RFBPC < 2562 ~ "D08",
                                       UF.x == 33 & RFBPC >= 2562 & RFBPC < 4095 ~ "D09",
                                       UF.x == 33 & RFBPC >= 4095 ~ "D10",
                                       UF.x == 24 & RFBPC < 297 ~ "D01",
                                       UF.x == 24 & RFBPC >= 297 & RFBPC < 405 ~ "D02",
                                       UF.x == 24 & RFBPC >= 405 & RFBPC < 512 ~ "D03",
                                       UF.x == 24 & RFBPC >= 512 & RFBPC < 658 ~ "D04",
                                       UF.x == 24 & RFBPC >= 658 & RFBPC < 820 ~ "D05",
                                       UF.x == 24 & RFBPC >= 820 & RFBPC < 1019 ~ "D06",
                                       UF.x == 24 & RFBPC >= 1019 & RFBPC < 1237 ~ "D07",
                                       UF.x == 24 & RFBPC >= 1237 & RFBPC < 1611 ~ "D08",
                                       UF.x == 24 & RFBPC >= 1611 & RFBPC < 2371 ~ "D09",
                                       UF.x == 24 & RFBPC >= 2371 ~ "D10",
                                       UF.x == 43 & RFBPC < 549 ~ "D01",
                                       UF.x == 43 & RFBPC >= 549 & RFBPC < 814 ~ "D02",
                                       UF.x == 43 & RFBPC >= 814 & RFBPC < 1070 ~ "D03",
                                       UF.x == 43 & RFBPC >= 1070 & RFBPC < 1315 ~ "D04",
                                       UF.x == 43 & RFBPC >= 1315 & RFBPC < 1572 ~ "D05",
                                       UF.x == 43 & RFBPC >= 1572 & RFBPC < 1879 ~ "D06",
                                       UF.x == 43 & RFBPC >= 1879 & RFBPC < 2289 ~ "D07",
                                       UF.x == 43 & RFBPC >= 2289 & RFBPC < 3010 ~ "D08",
                                       UF.x == 43 & RFBPC >= 3010 & RFBPC < 4328 ~ "D09",
                                       UF.x == 43 & RFBPC >= 4328 ~ "D10",
                                       UF.x == 11 & RFBPC < 326 ~ "D01",
                                       UF.x == 11 & RFBPC >= 326 & RFBPC < 489 ~ "D02",
                                       UF.x == 11 & RFBPC >= 489 & RFBPC < 617 ~ "D03",
                                       UF.x == 11 & RFBPC >= 617 & RFBPC < 736 ~ "D04",
                                       UF.x == 11 & RFBPC >= 736 & RFBPC < 896 ~ "D05",
                                       UF.x == 11 & RFBPC >= 896 & RFBPC < 1061 ~ "D06",
                                       UF.x == 11 & RFBPC >= 1061 & RFBPC < 1335 ~ "D07",
                                       UF.x == 11 & RFBPC >= 1335 & RFBPC < 1680 ~ "D08",
                                       UF.x == 11 & RFBPC >= 1680 & RFBPC < 2496 ~ "D09",
                                       UF.x == 11 & RFBPC >= 2496 ~ "D10",
                                       UF.x == 14 & RFBPC < 220 ~ "D01",
                                       UF.x == 14 & RFBPC >= 220 & RFBPC < 320 ~ "D02",
                                       UF.x == 14 & RFBPC >= 320 & RFBPC < 429 ~ "D03",
                                       UF.x == 14 & RFBPC >= 429 & RFBPC < 558 ~ "D04",
                                       UF.x == 14 & RFBPC >= 558 & RFBPC < 758 ~ "D05",
                                       UF.x == 14 & RFBPC >= 758 & RFBPC < 987 ~ "D06",
                                       UF.x == 14 & RFBPC >= 987 & RFBPC < 1214 ~ "D07",
                                       UF.x == 14 & RFBPC >= 1214 & RFBPC < 1754 ~ "D08",
                                       UF.x == 14 & RFBPC >= 1754 & RFBPC < 2658 ~ "D09",
                                       UF.x == 14 & RFBPC >= 2658 ~ "D10",
                                       UF.x == 42 & RFBPC < 591 ~ "D01",
                                       UF.x == 42 & RFBPC >= 591 & RFBPC < 843 ~ "D02",
                                       UF.x == 42 & RFBPC >= 843 & RFBPC < 1084 ~ "D03",
                                       UF.x == 42 & RFBPC >= 1084 & RFBPC < 1322 ~ "D04",
                                       UF.x == 42 & RFBPC >= 1322 & RFBPC < 1548 ~ "D05",
                                       UF.x == 42 & RFBPC >= 1548 & RFBPC < 1838 ~ "D06",
                                       UF.x == 42 & RFBPC >= 1838 & RFBPC < 2261 ~ "D07",
                                       UF.x == 42 & RFBPC >= 2261 & RFBPC < 2833 ~ "D08",
                                       UF.x == 42 & RFBPC >= 2833 & RFBPC < 4106 ~ "D09",
                                       UF.x == 42 & RFBPC >= 4106 ~ "D10",
                                       UF.x == 35 & RFBPC < 515 ~ "D01",
                                       UF.x == 35 & RFBPC >= 515 & RFBPC < 763 ~ "D02",
                                       UF.x == 35 & RFBPC >= 763 & RFBPC < 986 ~ "D03",
                                       UF.x == 35 & RFBPC >= 986 & RFBPC < 1204 ~ "D04",
                                       UF.x == 35 & RFBPC >= 1204 & RFBPC < 1475 ~ "D05",
                                       UF.x == 35 & RFBPC >= 1475 & RFBPC < 1798 ~ "D06",
                                       UF.x == 35 & RFBPC >= 1798 & RFBPC < 2274 ~ "D07",
                                       UF.x == 35 & RFBPC >= 2274 & RFBPC < 3142 ~ "D08",
                                       UF.x == 35 & RFBPC >= 3142 & RFBPC < 5155 ~ "D09",
                                       UF.x == 35 & RFBPC >= 5155 ~ "D10",
                                       UF.x == 28 & RFBPC < 341 ~ "D01",
                                       UF.x == 28 & RFBPC >= 341 & RFBPC < 460 ~ "D02",
                                       UF.x == 28 & RFBPC >= 460 & RFBPC < 576 ~ "D03",
                                       UF.x == 28 & RFBPC >= 576 & RFBPC < 719 ~ "D04",
                                       UF.x == 28 & RFBPC >= 719 & RFBPC < 886 ~ "D05",
                                       UF.x == 28 & RFBPC >= 886 & RFBPC < 1117 ~ "D06",
                                       UF.x == 28 & RFBPC >= 1117 & RFBPC < 1415 ~ "D07",
                                       UF.x == 28 & RFBPC >= 1415 & RFBPC < 1833 ~ "D08",
                                       UF.x == 28 & RFBPC >= 1833 & RFBPC < 3007 ~ "D09",
                                       UF.x == 28 & RFBPC >= 3007 ~ "D10",
                                       UF.x == 17 & RFBPC < 214 ~ "D01",
                                       UF.x == 17 & RFBPC >= 214 & RFBPC < 337 ~ "D02",
                                       UF.x == 17 & RFBPC >= 337 & RFBPC < 445 ~ "D03",
                                       UF.x == 17 & RFBPC >= 445 & RFBPC < 564 ~ "D04",
                                       UF.x == 17 & RFBPC >= 564 & RFBPC < 693 ~ "D05",
                                       UF.x == 17 & RFBPC >= 693 & RFBPC < 794 ~ "D06",
                                       UF.x == 17 & RFBPC >= 794 & RFBPC < 984 ~ "D07",
                                       UF.x == 17 & RFBPC >= 984 & RFBPC < 1234 ~ "D08",
                                       UF.x == 17 & RFBPC >= 1234 & RFBPC < 1976 ~ "D09",
                                       UF.x == 17 & RFBPC >= 1976 ~ "D10"))

### Estatisticas descritivas (4.2)

temp1 = svyby(~Pessoas, ~D_RFBPC, Morador_design, svytotal, keep.var = F, keep.names = F)

temp2 = svyby(~Num_morador, ~D_RFBPC, Morador_design, svymean, keep.var = F, keep.names = F)

temp3 = svyby(~RFBPC, ~D_RFBPC, Morador_design, svymean, keep.var = F, keep.names = F)

temp4 = svyby(~Pob_RFBPC, ~D_RFBPC, Morador_design, svytotal, keep.var = F, keep.names = F)

temp5 = svyby(~Hiato_RFBPC, ~D_RFBPC, Morador_design, svymean, keep.var = F, keep.names = F, 
              na.rm = T)

temp = data.frame("Decimos" = temp1$D_RFBPC,
                  "Pessoas" = round(temp1$statistic),
                  "Pes_Dom" = round(temp2$statistic),
                  "RFBPC_M" = round(temp3$statistic),
                  "N_pobres" = round(temp4$statistic),
                  "H_pobreza" = round(temp5$statistic)) %>%
  mutate(H_pobreza = ifelse(is.nan(H_pobreza), 0, H_pobreza),
         "Familias" = round(Pessoas / Pes_Dom))

rm(temp1, temp2, temp3, temp4, temp5)

### Decimos de renda por atividade economica do SCN (4.3)

# Gerando base com decimos de renda de cada UC (familia)

Morador = as.data.frame(Morador)

temp1 = Morador %>%
  select(ID_UC, D_RFBPC) %>%
  unique()

# Relacionado base com despesas por atividade economica com decimos da RFBPC

base_trab = left_join(base_trab, temp1, "ID_UC")

# Finalizando estatisticas descritivas

temp1 = base_trab %>%
  group_by(D_RFBPC) %>%
  summarise("Desp_T" = sum(DESP_F))

Tab1_POF = data.frame(temp,
                      "P_D_T" = round(temp1$Desp_T / sum(temp1$Desp_T) * 100, 
                                      digits = 2))

write.xlsx(Tab1_POF,
           file = "...")

# Resultado por atividade SCN e decil

Tab2_POF = base_trab %>%
  group_by(SCN_18SET, D_RFBPC) %>%
  summarise("Desp_T" = sum(DESP_F))

Tab2_POF = pivot_wider(Tab2_POF, names_from = D_RFBPC, values_from = Desp_T)

write.xlsx(Tab2_POF,
           file = "...")


###+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
### TESTANDO GERACAO DE RESULTADOS (5)
###+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
## Relacionamento do tradutor de despesas com as despesas por produtos (3.1)
# Este passo e efetuado para checagem com os resultados da tebela de despesa
# divulgada pelo IBGE (Tab 6715 - SIDRA)

tradutor_despesa <-
  readxl::read_excel("...") 

Despesas = left_join(Despesas, tradutor_despesa, by = c("PROD_5D" = "Codigo"))

# Concomitantimente, calculando as Despesas anuais com bens e servicos 2 = DESP_A2
# Essa var e criada para considerar somente as contas da tabela de despesa geral,
# conforme tradutor de despesas

Despesas = Despesas %>% 
  mutate(DESP_A2 = case_when(Variavel == "V1904_DEFLA" ~ INSS_A,
                             Variavel == "V531112_DEFLA" ~ CPP_A,
                             Variavel == "V531122_DEFLA" ~ IRPF_A,
                             Variavel == "V531132_DEFLA" ~ ISSQN_A,
                             Variavel == "V8000_DEFLA" ~ DESP_A,
                             Variavel == "V8501_DEFLA" ~ DEDUCOES_A,
                             TRUE ~ NA)) %>% 
  drop_na(DESP_A2) %>%
  mutate("DESP_M" = round(DESP_A2 / 12, digits = 2))

# Despesa monetária e não monetária média mensal familiar - por UF

Despesas %>% 
  filter(V0306 == 1 & UF.x == 21) %>%
  group_by(Classes, Descricao_0) %>% 
  summarise(Valor = round(sum(DESP_M, na.rm = T) / FAMS, digits = 2)) %>% 
  unique() %>% 
  drop_na() %>%
  pivot_wider(names_from = Classes, values_from = Valor) %>%
  print(n = 27)


###+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
### GERACAO DE RESULTADOS DO INVENTARIO (5)
###+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# Servira de base aqui, os microdados do caderno 'inventario' que fornece a re
# lacao de bens duraveis do domicilio principal;
# Bem como os micrdados do caderno 'Morador', aonde obtém o total de familias

### Manipulacao do caderno Inventario (4.1)

Inventario = Inventario %>% 
  filter(UF == 21) %>% 
  select(COD_UPA, V9001, V9005) %>% 
  group_by(COD_UPA, V9001) %>% 
  summarise("Bens" = round(sum(V9005)))

Inventario = Inventario %>% 
  group_by(COD_UPA) %>% 
  pivot_wider(names_from = V9001,
              values_from = Bens,
              values_fill = list(n = 0))

Inventario = Inventario %>% 
  mutate_all(replace_na, 0)

### Manipulacao do caderno Domicilio (4.2)

Domicilio = Domicilio %>% 
  filter(UF == 21) %>% 
  select(UF, ESTRATO_POF, TIPO_SITUACAO_REG, COD_UPA, PESO_FINAL) %>% 
  group_by(COD_UPA) %>% 
  mutate("N_Dom" = round(sum(PESO_FINAL)))

Domicilio = unique(Domicilio)

### Gerando base de Inventario por domicilio por UPA (4.2)

Bens_Dom = left_join(Domicilio, Inventario, by = "COD_UPA")

Bens_Dom = Bens_Dom %>% 
  pivot_longer(cols = c(7:38),
               names_to = "Produtos",
               values_to = "Quantidade")

Bens_Dom = Bens_Dom %>% 
  mutate(Quantidade = round(Quantidade * PESO_FINAL)) %>% 
  mutate("Qtd_Dom" = round(Quantidade / N_Dom))

rm(Domicilio, Inventario)

## Relacionamento do tradutor de produtos com inventario (4.3)

tradutor_prods <-
  readxl::read_excel("...") 

Inventario = left_join(Bens_Dom, 
                       tradutor_prods, 
                       by = c("Produtos" = "CÓDIGO DO PRODUTO"))

openxlsx::write.xlsx(x = Inventario,
                     file = "...")


###+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
###
###+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

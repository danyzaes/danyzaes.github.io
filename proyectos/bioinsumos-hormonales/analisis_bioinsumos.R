# ==============================================================================
# Proyecto: Evaluación Multivariada de Bioinsumos y Fitohormonas (IAA/GA3) 
#           bajo Estrés Salino en Vivero
# Autora: Ledy Daniela Zamora Esquivel
# Herramientas: RStudio (tidyverse, ggplot2, rstatix)
# ==============================================================================

library(tidyverse)

# 1. Establecer directorio de trabajo
setwd("C:/Users/danyz/OneDrive/Escritorio/creacion de portafolio/fitohormonas y bioestimulantes")

# 2. Cargar datos
datos_bioinsumos <- read_delim(
  file = "bioinputs_hormonal_assay.csv",
  delim = ";",
  locale = locale(decimal_mark = ".")
)

# Convertir variables categóricas a factores ordenados
datos_bioinsumos <- datos_bioinsumos %>%
  mutate(
    tratamiento = factor(tratamiento, levels = c("Control", "Extracto_A1", "Consorcio_B2")),
    nivel_estres_NaCl_mM = factor(nivel_estres_NaCl_mM, levels = c(0, 50, 100)),
    muestreo_semana = factor(muestreo_semana, levels = c("semana_2", "semana_4", "semana_6", "semana_8"))
  )

# 3. Filtrar datos de la evaluación final (Semana 8)
datos_s8 <- datos_bioinsumos %>% filter(muestreo_semana == "semana_8")

# 4. ANOVA de dos vías (Tratamiento x Estrés) para Concentración de IAA
anova_iaa <- aov(iaa_ppm ~ tratamiento * nivel_estres_NaCl_mM, data = datos_s8)
summary(anova_iaa)

# 5. Gráfico 1: Producción de IAA (Fitohormona) bajo Gradiente de Salinidad (Semana 8)
# Resumen de Medias y Errores Estándar
resumen_iaa <- datos_s8 %>%
  group_by(tratamiento, nivel_estres_NaCl_mM) %>%
  summarise(
    media_iaa = mean(iaa_ppm),
    se_iaa = sd(iaa_ppm) / sqrt(n()),
    .groups = "drop"
  )

ggplot(resumen_iaa, aes(x = nivel_estres_NaCl_mM, y = media_iaa, fill = tratamiento)) +
  geom_bar(stat = "identity", position = position_dodge(0.8), width = 0.7, color = "black") +
  geom_errorbar(
    aes(ymin = media_iaa - se_iaa, ymax = media_iaa + se_iaa),
    position = position_dodge(0.8),
    width = 0.25,
    linewidth = 0.7
  ) +
  scale_fill_manual(values = c("Control" = "#cccccc", "Extracto_A1" = "#74c476", "Consorcio_B2" = "#238b45")) +
  labs(
    title = "Efecto Bioprotector de Bioinsumos sobre la Síntesis de IAA (Semana 8)",
    subtitle = "Interacción Tratamiento × Estrés Salino (NaCl mM) [Media ± EE, n=4]",
    x = "Concentración de Estrés Salino NaCl (mM)",
    y = "Ácido Indolacético - IAA (ppm)",
    fill = "Bioinsumo Aplicado"
  ) +
  theme_minimal() +
  theme(
    legend.position = "bottom",
    plot.title = element_text(face = "bold", size = 13)
  )

# 6. Gráfico 2: Relación Biomasa Seca vs Prolina (Ajuste Osmótico bajo Estrés)
ggplot(datos_bioinsumos, aes(x = prolina_umol_g, y = biomasa_seca_g, color = tratamiento, shape = nivel_estres_NaCl_mM)) +
  geom_point(size = 3, alpha = 0.8) +
  geom_smooth(method = "lm", se = FALSE, linetype = "dashed", linewidth = 0.8) +
  scale_color_manual(values = c("Control" = "#cb181d", "Extracto_A1" = "#3182bd", "Consorcio_B2" = "#31a354")) +
  labs(
    title = "Mitigación del Estrés Salino: Prolina Osmoprotectora vs Biomasa Acumulada",
    subtitle = "Trayectoria Temporal (S2 a S8) por Tratamiento y Nivel de NaCl",
    x = "Concentración de Prolina (µmol/g tejido fresco)",
    y = "Biomasa Seca Vegetal (g)",
    color = "Bioinsumo",
    shape = "NaCl (mM)"
  ) +
  theme_minimal() +
  theme(
    legend.position = "bottom",
    plot.title = element_text(face = "bold", size = 13)
  )

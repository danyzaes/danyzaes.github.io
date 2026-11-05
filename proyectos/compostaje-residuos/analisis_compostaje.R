# ==============================================================================
# Proyecto: Perfil Térmico y Cinetica de Maduración en Compostaje de Residuos
# Autora: Ledy Daniela Zamora Esquivel
# Herramientas: RStudio (tidyverse, ggplot2)
# ==============================================================================

library(tidyverse)

# 1. Establecer directorio de trabajo
setwd("C:/Users/danyz/OneDrive/Escritorio/creacion de portafolio/compost")

# 2. Cargar datos
datos_compost <- read_delim(
  file = "compost_kinetics_data.csv",
  delim = ";",
  locale = locale(decimal_mark = ".")
)

# 3. Categorización de Fases Térmicas
datos_compost <- datos_compost %>%
  mutate(
    fase = case_when(
      dia <= 4 ~ "Mesofílica",
      dia >= 5 & dia <= 14 ~ "Termofílica (Higienización)",
      dia >= 15 & dia <= 30 ~ "Enfriamiento",
      TRUE ~ "Maduración / Estabilización (25°C)"
    )
  )

# 4. Gráfico 1: Perfil Térmico y Zonas de Higienización
ggplot(datos_compost, aes(x = dia)) +
  geom_ribbon(aes(ymin = temperatura_ambiente_C, ymax = temperatura_compost_C), fill = "#fee08b", alpha = 0.4) +
  geom_line(aes(y = temperatura_compost_C, color = "Temperatura Compost (°C)"), linewidth = 1.2) +
  geom_line(aes(y = temperatura_ambiente_C, color = "Temperatura Ambiente (°C)"), linetype = "dashed", linewidth = 0.9) +
  geom_hline(yintercept = 55, linetype = "dotted", color = "#d73027", linewidth = 1) +
  annotate("text", x = 10, y = 57, label = "Umbral de Higienización (> 55°C)", color = "#d73027", fontface = "bold") +
  scale_color_manual(values = c(
    "Temperatura Compost (°C)" = "#d73027",
    "Temperatura Ambiente (°C)" = "#4575b4"
  )) +
  labs(
    title = "Evolución Perfil Térmico en Compostaje de Residuos (50 Días)",
    subtitle = "Fases: Mesofílica, Termofílica (>55°C), Enfriamiento y Maduración Estabilizada (25°C)",
    x = "Tiempo de Monitoreo (Días)",
    y = "Temperatura (°C)",
    color = "Medición"
  ) +
  theme_minimal() +
  theme(
    legend.position = "bottom",
    plot.title = element_text(face = "bold", size = 13)
  )

# 5. Gráfico 2: Relación C/N y Evolución de pH
ggplot(datos_compost, aes(x = dia)) +
  geom_line(aes(y = relacion_cn, color = "Relación C/N"), linewidth = 1.1) +
  geom_line(aes(y = pH * 3, color = "pH (Escala x3)"), linewidth = 1.1, linetype = "dotdash") +
  geom_hline(yintercept = 15, linetype = "dashed", color = "#2b83ba", linewidth = 0.8) +
  annotate("text", x = 40, y = 16.5, label = "C/N Óptimo Maduro (< 15)", color = "#2b83ba", fontface = "italic") +
  scale_y_continuous(
    name = "Relación C/N",
    sec.axis = sec_axis(~ . / 3, name = "pH")
  ) +
  scale_color_manual(values = c(
    "Relación C/N" = "#e66101",
    "pH (Escala x3)" = "#5e3c99"
  )) +
  labs(
    title = "Dinámica de Humificación: C/N vs pH",
    subtitle = "Indicadores de Madurez Biológica y Estabilización del Abono",
    x = "Días de Operación",
    color = "Parámetro"
  ) +
  theme_minimal() +
  theme(
    legend.position = "bottom",
    plot.title = element_text(face = "bold", size = 13)
  )

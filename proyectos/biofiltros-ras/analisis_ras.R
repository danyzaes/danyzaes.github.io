# ==============================================================================
# Proyecto: Evaluación Cinética de Nitrificación y Eficiencia en Biofiltros RAS
# Autora: Ledy Daniela Zamora Esquivel
# Herramientas: RStudio (tidyverse, ggplot2)
# ==============================================================================

library(tidyverse)

# 1. Directorio de trabajo
setwd("C:/Users/danyz/OneDrive/Escritorio/creacion de portafolio/bases de datos")

# 2. Cargar datos e interpretar comas como decimales
datos_ras <- read_delim(
  file = "ras_biofilter_data.csv",
  delim = ";",
  locale = locale(decimal_mark = ",")
)

# 3. Conversión limpia a numérico
datos_ras <- datos_ras %>%
  mutate(across(
    .cols = c(amonio_in_mgL, amonio_out_mgL, nitrito_out_mgL, nitrato_out_mgL),
    .fns = ~ as.numeric(gsub(",", ".", as.character(.)))
  )) %>%
  mutate(
    amonio_in_mgL = ifelse(amonio_in_mgL > 20, amonio_in_mgL / 100, amonio_in_mgL)
  )

# 4. Calcular Eficiencia de Remoción (%) de TAN
datos_ras <- datos_ras %>%
  mutate(
    eficiencia_tan_pct = ((amonio_in_mgL - amonio_out_mgL) / amonio_in_mgL) * 100
  )

# 5. Gráfico 1: Dinámica Completa del Ciclo de Nitrificación (Líneas Continuas D1-40)
ggplot(datos_ras, aes(x = dia)) +
  geom_line(aes(y = amonio_out_mgL, color = "TAN Efluente (NH4+)"), linewidth = 1.1) +
  geom_line(aes(y = nitrito_out_mgL, color = "Nitrito (NO2-)"), linewidth = 1.1) +
  geom_line(aes(y = nitrato_out_mgL / 45, color = "Nitrato (NO3- / 45)"), linewidth = 1.1, linetype = "dashed") +
  scale_y_continuous(
    name = "Concentración TAN y NO2- (mg/L)",
    sec.axis = sec_axis(~ . * 45, name = "Concentración NO3- (mg/L)")
  ) +
  scale_color_manual(values = c(
    "TAN Efluente (NH4+)" = "#d95f02", 
    "Nitrito (NO2-)" = "#7570b3", 
    "Nitrato (NO3- / 45)" = "#1b9e77"
  )) +
  labs(
    title = "Dinámica Cinética de Nitrificación en Biofiltro RAS (40 Días)",
    subtitle = "Fases: Maduración inicial (D1-10), Pico de Nitritos (D11-18) y Estado Estacionario (D20-40)",
    x = "Tiempo de Operación (Días)",
    color = "Parámetro Nitrogenado"
  ) +
  theme_minimal() +
  theme(
    legend.position = "bottom",
    plot.title = element_text(face = "bold", size = 13)
  )

# 6. Gráfico 2: Estabilización de la Eficiencia de Remoción (%)
ggplot(datos_ras, aes(x = dia, y = eficiencia_tan_pct)) +
  geom_point(color = "#2c7fb8", alpha = 0.7, size = 2.5) +
  geom_smooth(method = "gam", color = "#006d2c", se = TRUE) +
  geom_hline(yintercept = 90, linetype = "dotted", color = "red", linewidth = 1) +
  annotate("text", x = 32, y = 88, label = "Umbral Óptimo > 90%", color = "red", fontface = "italic") +
  scale_y_continuous(limits = c(0, 100)) +
  labs(
    title = "Evolución de la Eficiencia de Remoción de Amonio (TAN %)",
    x = "Días de Operación",
    y = "Eficiencia (%)"
  ) +
  theme_minimal()

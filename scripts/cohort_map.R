library(dplyr)
library(sf)
library(here)
library(ggplot2)
library(ggtext)
library(rnaturalearth)
library(rcartocolor)
library (readxl)
library(ggrepel)
library(cowplot)

theme_set(theme_minimal(base_size = 12,
                        base_family = "Arial"))

theme_update(
  plot.title.position = "plot",
  # left-align title
  plot.caption.position = "plot",
  # right-align caption
  plot.title = element_text(face = "bold"),
  # larger, bold title
  plot.subtitle = element_textbox_simple(color = "grey30",
    margin = ggplot2::margin(t = 0, b = 12, r = 30)),
  plot.caption = element_markdown(color = "grey30"),
  # change color of caption
  panel.grid.minor = element_blank()) # no minor grid lines

cols <- c("#363e7e", 'dodgerblue2', "#4aaaa5", "#a3d39c", "#f6b61c", "chocolate2", "red3", "violetred4")

# read in ssl site data
sites <- readxl::read_xlsx(here('data', "ssl-sites.xlsx"))
sites <- sites |> mutate(Region = as.factor(Region))

## wSSL and eSSL map sites----------------------------------------------------------

site.list <- sites %>% distinct(Region, RegionNumber)

ssl.sites <- 
  sites |> filter_at(vars(Latitude, Longitude), all_vars(!is.na(.))) |> 
  filter(Rookery == 1) |> 
  filter(RegionNumber < 12) %>%
  transform(dps = ifelse(Region %in% c('W ALEU', 'C ALEU', 'E ALEU', 'W GULF', 'C GULF', 'E GULF'),
                         'wDPS', 'eDPS'))
ssl.sites$Region <- factor(ssl.sites$Region, 
        levels = c('W ALEU', 'C ALEU', 'E ALEU', 'W GULF', 'C GULF', 'E GULF',
                   'SE AK', 'BC', 'WASH', 'OREGON', 'CALIF')) 

# w base maps --------------------------------------------------------------------
alaska_base <- rnaturalearth::ne_states("United States of America", return = "sf") |> 
  dplyr::filter(name == "Alaska") |> 
  sf::st_transform(3338)
russia_base <- rnaturalearth::ne_states("Russia", return = "sf")  |>  
  sf::st_transform(3338)
canada_base <- rnaturalearth::ne_states("Canada", return = "sf") |> 
  sf::st_transform(3338)
japan_base <- rnaturalearth::ne_states("Japan", return = "sf") |> 
  sf::st_transform(3338)

## labels
sam_pass <- tibble(label = "Samalga Pass",
  longitude = -169.48, latitude = 52.78,
  hjust = 0.5, vjust = 0) |> 
  st_as_sf(coords = c('longitude','latitude'), crs = 4326) |> 
  st_transform(3338)

w_reg_labels <- tibble(
  label = c("W ALEU", "C ALEU", "E ALEU", "W GULF", "C GULF", "E GULF"),
  longitude = c(-185, -176, -166, -158, -151, -147),
  latitude = c(54.3, 53, 52.9, 54.2, 56.3, 59)) |> 
  st_as_sf(coords = c('longitude','latitude'), crs = 4326) |> 
  st_transform(3338)

w_map_labels <- tibble(
  label = c("Bering Sea","Gulf of Alaska"),
  longitude = c(-179,-152), latitude = c(58,50)) |> 
  st_as_sf(coords = c('longitude','latitude'), crs = 4326) |> 
  st_transform(3338)

#this wouldn't work.... some day automate
# https://stackoverflow.com/questions/32506444/ggplot-function-to-add-text-just-below-legend
# w_co_labels <- tibble(
#   label = c('4', '3', '6', '6', '3'),
#   label2 = c('52', '53', '166', '197', '96'), 
#   longitude = c(-185, -176, -166, -151, -147), 
#   latitude = c(53.5, 53, 52.9, 57, 59)) |> 
#   st_as_sf(coords = c('longitude','latitude'), crs = 4326) |> 
#   st_transform(3338)

wssl.sites <- ssl.sites %>% filter(dps == 'wDPS') %>%
  filter(SiteName %in% c('ULAK/HASGOX POINT', 'MARMOT', 'SUGARLOAF', 'UGAMAK/NORTH', 'UGAMAK/UGAMAK BAY', 
                         'SEAL ROCKS', 'WOODED (FISH)', 'AGATTU/GILLON POINT'))
wssl_sf <-  sf::st_as_sf(wssl.sites, coords = c('Longitude', 'Latitude'), 
                         crs = 4326)

##EGOA: 3 cohorts 96 avg from 2000-2017
##CGOA: 6 cohorts 197 avg
##EALEU: 6 cohorts 166 avg

##CALEU: 3 cohorts 53 avg
##WALEU: 4 cohorts 52 avg

##wDPS map plot-----------------------------------------------

wDPS_plot <- ggplot() +
  geom_sf(data = alaska_base, fill = "gray50", color = NA) +
  geom_sf_text(data = alaska_base, aes(label = 'Alaska'), size = 4) +
  geom_sf(data = canada_base, fill = "gray65", color = NA) +
  geom_sf(data = russia_base, fill = "gray65", color = NA) +
  geom_sf(data = wssl_sf %>% filter(), 
          aes(fill = as.factor(wssl.sites$Region)),
          size = 3, shape = 21, color = 'black') +
  scale_fill_manual(values = rev(cols)) +
  geom_sf_text(
    data = w_map_labels,
    aes(label = label), color = "gray70",
    fontface = 'italic') +
  geom_sf_text(data = w_reg_labels, aes(label = label), color = "gray5", size = 3) +
  coord_sf(xlim = c(-2.25e+06, 0.7e+06),
          ylim = c(-0.3e+06, 2e+06), expand = FALSE) +
  scale_x_continuous(breaks = c(180, -170, -160, -150, -140)) +
  guides(fill = guide_legend(nrow = 1)) +
  labs(title = " ",
       subtitle = "Western distinct population segment (DPS)") +
  theme(
    legend.position = "bottom",
    legend.spacing.x = unit(1.5, 'cm'),
    plot.title.position = 'panel',
    legend.title = element_blank(),
    legend.text.align = 0,
    legend.text = element_text(margin = margin(l = -2), size = 11),
    plot.title = element_text(size = 14, hjust = 0.5),
    axis.title = element_blank(),
    panel.border = element_rect(fill = NA, colour = 'grey')) +
  ggrepel::geom_text_repel(data = sam_pass,
    mapping = aes(label = label, geometry = geometry,
                  hjust = hjust, vjust = vjust, size = 4),
    nudge_x = c(-100000,rep(0,6)),
    nudge_y = c(-260000,0,-300000,0,0,0),
    stat = "sf_coordinates",
    min.segment.length = 0, size = 3.5,
    box.padding = 0.5, fontface = 'italic',
    color = "gray50")

### eDPS ---------------------

essl.sites <- ssl.sites %>% 
  filter(dps == 'eDPS' & SiteName %in% c('ST. GEORGE REEF', 'ROGUE REEF')) %>%
  transform(Region = ifelse(Region == 'CALIF', 'CALIFORNIA', 'OREGON'))
essl_sf <-  sf::st_as_sf(essl.sites, coords = c('Longitude', 'Latitude'), 
                         crs = 4326)

us_base <- rnaturalearth::ne_states("United States of America", return = "sf") |> 
  sf::st_transform(3310)
washington_base <- rnaturalearth::ne_states("United States of America", return = "sf") |> 
  dplyr::filter(name == "Washington") |> 
  sf::st_transform(3310)
oregon_base <- rnaturalearth::ne_states("United States of America", return = "sf") |> 
  dplyr::filter(name == "Oregon") |> 
  sf::st_transform(3310)
california_base <- rnaturalearth::ne_states("United States of America", return = "sf") |> 
  dplyr::filter(name == "California") |> 
  sf::st_transform(3310)
canada_base <- rnaturalearth::ne_states("Canada", return = "sf") |> 
  sf::st_transform(3310)

e_reg_labels <- tibble(
  label = c('SE AK', 'BC', 'WASH', 'OREGON', 'CALIF'),
  longitude = c(-147, -147, -147, -147, -147),
  latitude = c(50, 49, 48.5, 48, 47)) |> 
  st_as_sf(coords = c('longitude','latitude'), 
           crs = 4326) |>
  st_transform(3310)

e_map_labels <- tibble(
  label = c("Pacific Ocean"),
  longitude = c(-132), latitude = c(42)) |> 
  st_as_sf(coords = c('longitude','latitude'), crs = 4326) |> 
  st_transform(3310)

#cohort sizes and number
##CA: 2 cohorts 145 avg from 2001-2004
##OR: 8 cohorts 175 avg from 2001-2015

eDPS_plot <- ggplot() +
  geom_sf(data = us_base, fill = "gray65", color = NA) +
  geom_sf(data = canada_base, fill = "gray50", color = NA) +
  geom_sf(data = california_base, fill = "gray50", color = NA) +
  geom_sf_text(data = california_base, aes(label = 'California'), size = 4) +
  geom_sf(data = oregon_base, fill = "gray50", color = NA) +
  geom_sf_text(data = oregon_base, aes(label = 'Oregon'), size = 4) +
  geom_sf(data = washington_base, fill = "gray50", color = NA) +
  geom_sf_text(data = washington_base, aes(label = 'Washington'), size = 4) +
  geom_sf(data = essl_sf, 
          aes(fill = as.factor(essl.sites$Region)),
          size = 3, shape = 21, color = 'black') +
  scale_fill_manual(values = cols) +
  geom_sf_text(
    data = e_map_labels,
    aes(label = label),
    color = "gray70", size = 4,
    fontface = 'italic'
  ) +
  # annotate('text', y = 32, x = 130, label = 'Test') +
  geom_sf_text(data = e_reg_labels, aes(label = label), color = "gray5", size = 2) +
  coord_sf(
    xlim = c(-1500000, 650000),
    ylim = c(-300000, 1400000), expand = F) +
  scale_x_continuous(breaks = c(-140, -135, -130, -125, -120, -115, -110)) +
  scale_y_continuous(breaks = c(35, 40, 45, 50)) +
  guides(fill = guide_legend(nrow = 1, label.hjust = 1)) + #hjust seems to be doing nothing
  labs(title = " ",
       subtitle = "Eastern distinct population segment (DPS)", size = 14) +
  theme(
    # legend.text.align = 10,
    legend.spacing.x = unit(0.3, 'cm'),
    legend.position = "bottom",
    legend.text.align = 0,
    plot.title.position = 'panel',
    plot.title = element_text(size = 14, hjust = 0.5),
    legend.text = element_text(margin = margin(l = 0), size = 11),
    legend.title = element_blank(),
    panel.border = element_rect(fill = NA, colour = 'grey'),
    axis.title = element_blank()) 

plot_grid(wDPS_plot, eDPS_plot, nrow = 1, rel_heights = c(1.5, 0.75), scale = 0.9)


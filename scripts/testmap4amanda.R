library(dplyr)
library(sf)
library(here)
library(ggplot2)
library(ggtext)
library(rnaturalearth)
library(rcartocolor)
library (readxl)
library(ggrepel)

theme_set(theme_minimal(base_size = 10,
                        base_family = "Arial"))

theme_update(
  plot.title.position = "plot",
  # left-align title
  plot.caption.position = "plot",
  # right-align caption
  plot.title = element_text(face = "bold"),
  # larger, bold title
  plot.subtitle = element_textbox_simple(
    color = "grey30",
    margin = ggplot2::margin(t = 0, b = 12, r = 30)
  ),
  plot.caption = element_markdown(color = "grey30"),
  # change color of caption
  panel.grid.minor = element_blank() # no minor grid lines
)

# read in ssl site data
sites <- readxl::read_xlsx(here('data', "ssl-sites.xlsx"))
sites <- sites |> mutate(Region = as.factor(Region))

## wSSL only map sites----------------------------------------------------------
wssl.sites <- 
  sites |> filter_at(vars(Latitude, Longitude), all_vars(!is.na(.))) |> 
  filter(Rookery == 1) |> 
  filter(RegionNumber >= 6 & RegionNumber <= 12)
wssl.sites$Region <- factor(wssl.sites$Region, levels = c('BERING', 'W ALEU', 'C ALEU', 'E ALEU', 'W GULF', 'C GULF', 'E GULF'))

wssl_sf <-  sf::st_as_sf(wssl.sites, coords = c('Longitude', 'Latitude'), crs = 4326)

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

ssl_sf <-  sf::st_as_sf(ssl.sites, coords = c('Longitude', 'Latitude'), crs = 4326)

# base maps --------------------------------------------------------------------
alaska_base <- rnaturalearth::ne_states("United States of America", return = "sf") |> 
  dplyr::filter(name == "Alaska") |> 
  sf::st_transform(3338)
russia_base <- rnaturalearth::ne_states("Russia", return = "sf")  |>  
  sf::st_transform(3338)
canada_base <- rnaturalearth::ne_states("Canada", return = "sf") |> 
  sf::st_transform(3338)
japan_base <- rnaturalearth::ne_states("Japan", return = "sf") |> 
  sf::st_transform(3338)
washington_base <- rnaturalearth::ne_states("United States of America", return = "sf") |> 
  dplyr::filter(name == "Washington") |> 
  sf::st_transform(3338)
oregon_base <- rnaturalearth::ne_states("United States of America", return = "sf") |> 
  dplyr::filter(name == "Oregon") |> 
  sf::st_transform(3338)
california_base <- rnaturalearth::ne_states("United States of America", return = "sf") |> 
  dplyr::filter(name == "California") |> 
  sf::st_transform(3338)

map_labels <- tibble(
  label = c("Bering Sea","Gulf of Alaska"),
  longitude = c(-179,-148),
  latitude = c(57,54)
) |> 
  st_as_sf(coords = c('longitude','latitude'),
           crs = 4326) |> 
  st_transform(3338)

reg_labels <- tibble(
  label = c("BERING", "W ALEU", "C ALEU", "E ALEU", "W GULF", "C GULF", "E GULF"),
  longitude = c(-168, -185, -176, -166, -160, -151, -147),
  latitude = c(57, 53.5, 53, 52.9, 53.9, 57, 59)) |> 
  st_as_sf(coords = c('longitude','latitude'),
           crs = 4326) |> 
  st_transform(3338)

w_reg_labels <- tibble(
  label = c("W ALEU", "C ALEU", "E ALEU", "W GULF", "C GULF", "E GULF"),
  longitude = c(-185, -176, -166, -160, -151, -147),
  latitude = c(53.5, 53, 52.9, 53.9, 57, 59)) |> 
  st_as_sf(coords = c('longitude','latitude'),
           crs = 4326) |> 
  st_transform(3338)

e_reg_labels <- tibble(
  label = c('SE AK', 'BC', 'WASH', 'OREGON', 'CALIF'),
  longitude = c(-147, -147, -147, -147, -147),
  latitude = c(50, 49, 48.5, 48, 47)) |> 
  st_as_sf(coords = c('longitude','latitude'),
           crs = 4326) |> 
  st_transform(3338)

wssl_colors <- c(rcartocolor::carto_pal(6, 'Bold')[1:6],
                    rcartocolor::carto_pal(6, 'Pastel')[5])

## make some labels
sam_pass <- tibble(
  label = "Samalga Pass",
  longitude = -169.48,
  latitude = 52.78,
  hjust = 0.5,
  vjust = 0) |> 
  st_as_sf(coords = c('longitude','latitude'),
           crs = 4326) |> 
  st_transform(3338)


##plot wssl rookeries-----------------------------------------------
# ggplot() +
#   geom_sf(data = alaska_base, fill = "gray50", color = NA) +
#   geom_sf_text(data = alaska_base, aes(label = 'Alaska')) +
#   geom_sf(data = canada_base, fill = "gray65", color = NA) +
#   geom_sf(data = russia_base, fill = "gray65", color = NA) +
#   geom_sf(data = wssl_sf, 
#           aes(fill = as.factor(wssl.sites$Region)),
#           size = 3,
#           shape = 21,
#           color = 'black') +
#   scale_fill_manual(values = wssl_colors) +
# geom_sf_text(
#   data = map_labels,
#   aes(label = label),
#   color = "gray70",
#   fontface = 'italic'
# ) +
#   geom_sf_text(
#     data = reg_labels,
#     aes(label = label),
#     color = "gray5",
#     size = 2
#   ) +
#   coord_sf(
#     xlim = c(-2.25e+06, 0.7e+06),
#     ylim = c(-0.008e+06, 1.9e+06),
#     expand = FALSE
#   ) +
#   scale_x_continuous(breaks = c(180, -170, -160, -150, -140)) +
#   guides(fill = guide_legend(nrow = 1)) +
#   labs(title = "Western stock Steller sea lion rookeries in Alaska",
#        subtitle = "Regions used for western stock Steller sea lion population trend estimation in Alaska.") +
#   theme(
#     legend.position = "bottom",
#     legend.title = element_blank(),
#     axis.title = element_blank()
#   ) +
#   ggrepel::geom_text_repel(
#     data = sam_pass,
#     mapping = aes(label = label, geometry = geometry,
#                   hjust = hjust, vjust = vjust),
#     nudge_x = c(100000,rep(0,6)),
#     nudge_y = c(-200000,0,-300000,0,0,0),
#     stat = "sf_coordinates",
#     min.segment.length = 0,
#     size = 2.7,
#     box.padding = 0.5,
#     fontface = 'italic',
#     color = "gray50"
#   )

## adapt for survey design paper
#wDPS
ggplot() +
  geom_sf(data = alaska_base, fill = "gray50", color = NA) +
  geom_sf_text(data = alaska_base, aes(label = 'Alaska')) +
  geom_sf(data = canada_base, fill = "gray65", color = NA) +
  geom_sf(data = russia_base, fill = "gray65", color = NA) +
  # geom_sf(data = california_base, fill = "gray65", color = NA) +
  # geom_sf(data = oregon_base, fill = "gray65", color = NA) +
  # geom_sf(data = washington_base, fill = "gray65", color = NA) +
  geom_sf(data = ssl_sf %>% filter(dps == 'wDPS'), 
          aes(fill = as.factor(ssl.sites$Region)),
          size = 3, shape = 21, color = 'black') +
  # scale_fill_manual(values = wssl_colors) +
  geom_sf_text(
    data = map_labels,
    aes(label = label),
    color = "gray70",
    fontface = 'italic') +
  geom_sf_text(
    data = reg_labels, aes(label = label), color = "gray5", size = 2) +
  coord_sf(
    xlim = c(-2.25e+06, 0.7e+06),
    ylim = c(-0.008e+06, 1.9e+06),
    # xlim = c(-2.25e+06, 0.7e+07),
    # ylim = c(-5000000, 1.75e+06),
    expand = FALSE) +
  facet_wrap(~dps) +
  # scale_x_continuous(breaks = c(180, -170, -160, -150, -140)) +
  scale_x_continuous(breaks = c(180, -170, -160, -150, -140)) +
  guides(fill = guide_legend(nrow = 1)) +
  labs(title = "Western and eastern stock Steller sea lion rookeries",
       subtitle = "Regions where Steller sea lion cohorts have been marked and released.") +
  theme(
    legend.position = "bottom",
    legend.title = element_blank(),
    axis.title = element_blank() ) +
  ggrepel::geom_text_repel(
    data = sam_pass,
    mapping = aes(label = label, geometry = geometry,
                  hjust = hjust, vjust = vjust),
    nudge_x = c(100000,rep(0,6)),
    nudge_y = c(-200000,0,-300000,0,0,0),
    stat = "sf_coordinates",
    min.segment.length = 0,
    size = 2.7,
    box.padding = 0.5,
    fontface = 'italic',
    color = "gray50")

#eDPS
ggplot() +
  # geom_sf(data = alaska_base, fill = "gray50", color = NA) +
  # geom_sf_text(data = alaska_base, aes(label = 'Alaska')) +
  geom_sf(data = canada_base, fill = "gray65", color = NA) +
  # geom_sf(data = russia_base, fill = "gray65", color = NA) +
  geom_sf(data = california_base, fill = "gray65", color = NA) +
  geom_sf(data = oregon_base, fill = "gray65", color = NA) +
  geom_sf(data = washington_base, fill = "gray65", color = NA) +
  geom_sf(data = ssl_sf %>% filter(dps == 'wDPS'), 
          aes(fill = as.factor(ssl.sites$Region)),
          size = 3,
          shape = 21,
          color = 'black') +
  # scale_fill_manual(values = wssl_colors) +
  geom_sf_text(
    data = map_labels,
    aes(label = label),
    color = "gray70",
    fontface = 'italic'
  ) +
  geom_sf_text(
    data = reg_labels,
    aes(label = label),
    color = "gray5",
    size = 2
  ) +
  coord_sf(
    xlim = c(-2.25e+06, 0.7e+06),
    ylim = c(-0.008e+06, 1.9e+06),
    # xlim = c(-2.25e+06, 0.7e+07),
    # ylim = c(-5000000, 1.75e+06),
    expand = FALSE
  ) +
  facet_wrap(~dps) +
  # scale_x_continuous(breaks = c(180, -170, -160, -150, -140)) +
  scale_x_continuous(breaks = c(180, -170, -160, -150, -140)) +
  guides(fill = guide_legend(nrow = 1)) +
  labs(title = "Western and eastern stock Steller sea lion rookeries",
       subtitle = "Regions where Steller sea lion cohorts have been marked and released.") +
  theme(
    legend.position = "bottom",
    legend.title = element_blank(),
    axis.title = element_blank()
  ) +
  ggrepel::geom_text_repel(
    data = sam_pass,
    mapping = aes(label = label, geometry = geometry,
                  hjust = hjust, vjust = vjust),
    nudge_x = c(100000,rep(0,6)),
    nudge_y = c(-200000,0,-300000,0,0,0),
    stat = "sf_coordinates",
    min.segment.length = 0,
    size = 2.7,
    box.padding = 0.5,
    fontface = 'italic',
    color = "gray50"
  )

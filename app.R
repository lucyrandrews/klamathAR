source(here::here("R", "config.R"))

load(here("data", "huc6.rda"))
load(here("data", "nhdplushr.rda"))
load(here("data", "barriers.rda"))

# specify attributes to display in a table in the app
display_attrs <- c(
  "Name",
  "SARPID",
  "rank",
  "Source",
  "StreamSize",
  "River",
  "AnnualFlow",
  "TotDASqKm",
  "Purpose",
  "Passabilit",
  "FishScreen",
  "Feasibilit",
  "Recon",
  "Diversion",
  "LowheadDam",
  "NoStructur",
  "PassageFac",
  "OwnerType",
  "BarrierOwn",
  "EJTract",
  "EJTribal",
  "Subbasin",
  "Subwatersh",
  "County",
  "Active_150",
  "SARP_Notes"
)

# set up the user interface
ui <- fluidPage(
  titlePanel("Klamath Watershed Barriers"),
  radioButtons("basemap", "choose basemap:",
               choices = c(
                 "Aerial image" = "esri",
                 "OpenTopoMap" = "opentopomap"
               )), # Add OpenTopoMap option
  leafletOutput("map"),
  dataTableOutput("data_table")
)

# create the server
server <- function(input, output, session) {

  # start without a marker selected
  selected_marker <- reactiveVal(NULL)

  # specify persistent datatable options
  dataTableOptions <- list(
    pageLength = 10,
    fixedHeader = TRUE,
    autoWidth = TRUE,
    scrollX = TRUE
  )

  # create the map
  output$map <- renderLeaflet({
    leaflet() %>%
      addProviderTiles(providers$OpenStreetMap) %>%
      addPolygons(
        data = huc6,
        fillOpacity = 0,
        color = "black",
        weight = 2
      ) %>%
      addCircleMarkers(
        data = barriers,
        layerId = ~SARPID,
        color = "black",
        fillColor = "black",
        fillOpacity = 1,
        radius = 4,
        weight = 1
      )
  })

  # set basemap depending on radio button selection
  observe({
    basemap <- input$basemap

    leafletProxy("map") %>%
      clearTiles() %>%
      addTiles(
        urlTemplate = if (basemap == "opentopomap") {
          "https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png"
        } else {
          if (basemap == "esri") {
            "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}"
          } else {
            paste0("https://{s}.tile.thunderforest.com/landscape/{z}/{x}/{y}.png?apikey=", Sys.getenv("THUNDERFOREST_API_KEY"))
          }
        },
        attribution = if (basemap == "opentopomap") {
          'Map data &copy; <a href="https://opentopomap.org">OpenTopoMap</a> contributors'
        } else {
          if (basemap == "esri") {
            'Tiles &copy; Esri &mdash; Source: Esri, i-cubed, USDA, USGS, AEX, GeoEye, Getmapping, Aerogrid, IGN, IGP, UPR-EGP, and the GIS User Community'
          } else {
            'Map data &copy; <a href="https://www.thunderforest.com/">Thunderforest</a>'
          }
        }
      )
  })

  # set up click functionality for markers
  observeEvent(input$map_marker_click, {
    clicked_marker_id <- input$map_marker_click$id

    # toggle marker selection
    if (!is.null(selected_marker()) && clicked_marker_id == selected_marker()) {
      selected_marker(NULL)
      output$data_table <- renderDataTable(barriers[, display_attrs], options = dataTableOptions)
    } else {
      selected_marker(clicked_marker_id)
      selected_data <- st_drop_geometry(barriers[barriers$SARPID == clicked_marker_id, display_attrs])
      output$data_table <- renderDataTable(selected_data, options = dataTableOptions)
    }

    # update markers
    leafletProxy("map", data = barriers) %>%
      clearMarkers() %>%
      addCircleMarkers(
        layerId = ~SARPID,
        color = ~ifelse(barriers$SARPID == selected_marker(), "red", "black"),
        fillColor = ~ifelse(barriers$SARPID == selected_marker(), "red", "black"),
        fillOpacity = 1,
        radius = 4,
        weight = 1
      )
  })

  # display the full dataset initially
  output$data_table <- renderDataTable({
    st_drop_geometry(barriers[, display_attrs])
  }, options = dataTableOptions)
}

# run the app
shinyApp(ui, server)

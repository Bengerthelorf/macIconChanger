from pathlib import Path

application = Path(defines["app"]).resolve()
background_image = Path(defines["background"]).resolve()

format = "UDZO"
filesystem = "APFS"
size = "160M"

files = [str(application)]
symlinks = {"Applications": "/Applications"}

background = str(background_image)
show_status_bar = False
show_tab_view = False
show_toolbar = False
show_pathbar = False
show_sidebar = False

window_rect = ((200, 120), (660, 420))
default_view = "icon-view"
show_icon_preview = False
include_icon_view_settings = "auto"
include_list_view_settings = "auto"

arrange_by = None
grid_offset = (0, 0)
grid_spacing = 100
scroll_position = (0, 0)
label_pos = "bottom"
text_size = 14
icon_size = 112

icon_locations = {
    application.name: (170, 230),
    "Applications": (490, 230),
}

badge_icon = str(application)

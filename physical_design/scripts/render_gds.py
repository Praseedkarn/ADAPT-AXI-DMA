import os
import klayout.db as db
import klayout.lay as lay

gds = os.path.abspath("physical_design/gds/axi4_dma.gds")
out = os.path.abspath("physical_design/gds/axi4_dma_layout.png")

if not os.path.isfile(gds):
    raise FileNotFoundError(gds)

view = lay.LayoutView()

# Load the GDS directly from its filename
view.load_layout(gds, True)
view.max_hier()
view.zoom_fit()

# Render the layout
view.save_image(out, 2400, 2400)

if not os.path.isfile(out) or os.path.getsize(out) == 0:
    raise RuntimeError("PNG export failed")

print("GDSII rendering successful!")
print("Input:", gds)
print("Output:", out)
print(f"PNG size: {os.path.getsize(out) / 1048576:.2f} MB")

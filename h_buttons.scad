// Keyed horizontally-printable buttons

function HButton(
  radius,
  depth,
  impression_thickness,
  x_align = "CENTER",
  z_align = "BOTTOM"
) = [radius, depth, impression_thickness, x_align, z_align];

function get_height(hButton) = hButton[0]*(sqrt(2) + 1);

module h_button(hButton) {
  radius = hButton[0];
  depth = hButton[1];
  impression_thickness = hButton[2];
  x_align = hButton[3];
  z_align = hButton[4];
  height = get_height(hButton);

  true_depth = depth + impression_thickness - radius;

  x_pos
    = x_align == "BOTTOM" ? radius
    : x_align == "TOP" ? radius - height
    : 0;

  z_pos
    = z_align == "TRUE_BOTTOM" ? 0
    : z_align == "TOP" ? -depth - impression_thickness
    : -impression_thickness;


  translate([x_pos, 0, z_pos]) {
    hull() {
      cylinder(true_depth, radius, radius);
      rotate([0, 0, -45])
        cube([radius, radius, true_depth]);
      translate([0, 0, true_depth])
        sphere(radius);
    }
    translate([-radius, -radius, 0])
      cube([height, 2*radius, impression_thickness]);
  }
}

module housing(
  thickness, // general thickness of walls
  pi_rod_radius, // radius of the screw holes on the pi
  pi_rod_height, // height of the rods to pass through the pi, button shim, and the adapter
  pi_rod_spacing_x, // distance from the screw hole centers of the pi along the x axis
  pi_rod_spacing_y, // distance from the screw hole centers of the pi along the y axis
  pi_rod_clearance, // distance from the pi screw hole centers to the edge of the board
  pi_solder_clearance, // height of the solder joints on the underside of the pi
  button_shim_extension, // how much further the button shim sticks out beyond the pi
  button_shim_height, // distance from the bottom of the pi to the bottom of the shim
  button_x, // total width of a button
  button_opening_x, // width of the opening to reveal the button
  button_opening_z, // height of the opening to reveal the button
  button_offset, // distance from button E to its closest side of the board
  display_extension, // how much further the display sticks out beyond the button shim
  display_height, // distance between the bottom of the pi board and the bottom of the display board
) {
  inner_y = button_shim_extension + $tolerance/2 + pi_rod_spacing_y + 2*(pi_rod_radius + pi_rod_clearance);
  inner_x = pi_rod_spacing_x + 2*(pi_rod_radius + pi_rod_clearance);

  translate([-thickness,-thickness,-thickness])
    cube([inner_x + 2*thickness, inner_y + 2*thickness, thickness]);

  translate([pi_rod_radius + pi_rod_clearance, pi_rod_radius + pi_rod_clearance, 0])
    for (x = [0, 1])
      for (y = [0, 1])
        translate([x*pi_rod_spacing_x, y*pi_rod_spacing_y, 0]) {
          cylinder(pi_rod_height + pi_solder_clearance, pi_rod_radius - $tolerance/2, pi_rod_radius - $tolerance/2);
          cylinder(pi_solder_clearance, pi_rod_clearance, pi_rod_clearance);
        }

  bottom_of_button_z = button_shim_height + pi_solder_clearance;

  translate([0, inner_y, 0])
    difference() {
      cube([inner_x, thickness, bottom_of_button_z + button_opening_z]);
      for (i = [0:4]) {
        translate([i * button_x + thickness + button_offset, 0, bottom_of_button_z])
          cube([button_opening_x, thickness, button_opening_z]);
      }
    }

  button_shim_to_display_dist = display_extension - button_shim_extension;
  button_shim_bottom_to_display_bottom = display_height - button_shim_height - button_opening_z;

  translate([0, inner_y, bottom_of_button_z + button_opening_z])
  rotate([90, 0, 0])
  rotate([0, 90, 0])
  linear_extrude(inner_x)
    polygon(
      [ [0,0]
      , [0, button_shim_bottom_to_display_bottom]
      , [thickness + button_shim_to_display_dist, button_shim_bottom_to_display_bottom]
      , [thickness, 0]
      ]
    );
}

housing(
  thickness = 3,
  pi_rod_radius = 1.5,
  pi_rod_height = 18,
  pi_rod_spacing_x = 60,
  pi_rod_spacing_y = 30,
  pi_rod_clearance = 3,
  pi_solder_clearance = 1.25,
  button_shim_extension = 4,
  button_shim_height = 6,
  button_x = 8,
  button_opening_x = 6,
  button_opening_z = 3,
  button_offset = 22,
  display_extension = 7,
  display_height = 22,
  $fn=60,
  $tolerance = 0.7
);

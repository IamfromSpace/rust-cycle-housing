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
  display_guide_radius, // radius of the screw holes on the display board
  display_guide_dist, // distance between the screw holes along the button-side edge
  display_guide_offset_y, // distance between top of the board the screw holes
  display_board_thickness, // thickness of the display board
  battery_length, // length of the battery along the parallel non-wire side
  battery_width, // length of the battery along the side with the wire
  battery_thickness, // smallest dimension of the battery
  sd_card_protrusion, // how far out of the board the sd card sits
  explode = 20, // (view only) separation between components when rendering
) {
  inner_y = button_shim_extension + $tolerance + pi_rod_spacing_y + 2*pi_rod_clearance;
  pi_length_x = pi_rod_spacing_x + 2*pi_rod_clearance;
  pi_offset_x = sd_card_protrusion;
  inner_x = sd_card_protrusion + pi_length_x + $tolerance;

  translate([0, 0, -thickness - battery_thickness -$tolerance - explode]) {
    translate([-thickness, -thickness, -thickness])
      cube([battery_length + 2*thickness + $tolerance, battery_width + 2*thickness + $tolerance, thickness]);
    for (i = [0,1])
      translate([-thickness, i*(battery_width + $tolerance + thickness) - thickness, 0])
        cube([battery_length + 2*thickness + $tolerance, thickness, battery_thickness + $tolerance]);
    for (i = [0,1])
      translate([i*(battery_length + $tolerance + thickness) - thickness, -thickness, 0])
        cube([thickness, battery_width + 2*thickness + $tolerance, battery_thickness + $tolerance]);
  }

  translate([-thickness - $tolerance/2,-thickness - $tolerance/2,-thickness])
    cube([inner_x + 2*thickness, inner_y + 2*thickness, thickness]);

  translate([pi_offset_x + pi_rod_clearance, pi_rod_clearance, 0])
    for (x = [0, 1])
      for (y = [0, 1])
        translate([x*pi_rod_spacing_x, y*pi_rod_spacing_y, 0]) {
          cylinder(pi_rod_height + pi_solder_clearance, pi_rod_radius - $tolerance/2, pi_rod_radius - $tolerance/2);
          cylinder(pi_solder_clearance, pi_rod_clearance, pi_rod_clearance);
        }

  translate([0, inner_y - $tolerance/2, 0])
    button_wall(
      thickness,
      inner_x,
      display_height + pi_solder_clearance,
      button_x,
      button_opening_x,
      button_opening_z,
      pi_offset_x + button_offset,
      button_shim_height + pi_solder_clearance,
      display_extension - button_shim_extension,
      display_guide_radius,
      display_board_thickness,
      display_guide_dist,
      display_guide_offset_y,
      pi_offset_x + pi_length_x/2
    );
}

module button_wall(
  thickness, // wall thickness
  length, // how long the wall should be
  height, // height of the wall _excluding_ the display guides
  button_x, // total width of a button
  button_opening_x, // width of the button opening
  button_opening_z, // width of the button opening
  button_offset_x, // offset for the buttons
  button_offset_z, // offset for the buttons
  extension, // how much further the top of the wall should extend
  display_guide_radius, // radius of the screw holes on the display board
  display_guide_thickness, // thickness of the display board
  display_guide_dist, // distance between the screw holes along the button-side edge
  display_guide_offset_y, // distance between top of the board the screw holes
  display_board_center_offset // how far the center of the display board is from the origin
) {
  difference() {
    cube([length, thickness, button_offset_z + button_opening_z]);
    for (i = [0:4]) {
      translate([i * button_x + thickness + button_offset_x, 0, button_offset_z])
        cube([button_opening_x, thickness, button_opening_z]);
    }
  }

  button_shim_bottom_to_display_bottom = height - button_offset_z - button_opening_z;

  translate([0, 0, button_offset_z + button_opening_z])
  rotate([90, 0, 0])
  rotate([0, 90, 0])
  linear_extrude(length)
    polygon(
      [ [0,0]
      , [0, button_shim_bottom_to_display_bottom]
      , [thickness + extension, button_shim_bottom_to_display_bottom]
      , [thickness, 0]
      ]
    );

  translate([0, -display_guide_radius, height])
    difference () {
      for(i = [-1,1])
        translate([display_board_center_offset + i * display_guide_dist/2, extension - display_guide_offset_y, 0])
          cylinder(display_guide_thickness, display_guide_radius - $tolerance/2, display_guide_radius - $tolerance/2);
      translate([0, -display_guide_radius, 0])
        cube([2*display_board_center_offset, 2*display_guide_radius, display_guide_thickness]);

    }
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
  display_extension = 8.5,
  display_height = 22,
  display_guide_radius = 2,
  display_guide_dist = 30,
  display_guide_offset_y = 2,
  display_board_thickness = 1.5,
  battery_length = 50,
  battery_width = 40,
  battery_thickness = 7,
  sd_card_protrusion = 3,
  $fn=60,
  $tolerance = 0.7
);

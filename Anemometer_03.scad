
use <./Library/screw.scad>;

$distance = 185;
$flat_corners = 20;
$corner_radius = 10;
$material_thickness = 5;
$tube_diameter = 16;

$wall_length = 100;
$bottom_hole = 100;
$height = 50;

$tolerance = 0.01;
$fn = 10;
$scale_factor = 72.0 / 25.4;

module screws_and_bolts()
{ 
  for(k=[0,180])
    rotate(v=[1,0,0], a=k)
      translate([0,0,$height/2])
        for(j=[0,90,180,270])
          rotate(v=[0,0,1], a=j)
            //for(i=[-2*$wall_length/7, -$tube_diameter/2, $tube_diameter/2, 2*$wall_length/7])
            for(i=[-2*$wall_length/7, 2*$wall_length/7])
              translate([i,-($distance-$tube_diameter-$material_thickness)/2,0])
                screw_m25(18.5);
}

module tube_holes()
{
  for(a=[0, 90, 180, 270])
    rotate(a=a, v=[0,0,1])
      translate([$distance/2, 0, 0])
        cylinder(d=$tube_diameter, h=$material_thickness+$tolerance, center=true); 
};

module plate()
{
  $minkowski_distance = $distance-(2*$corner_radius);
  $minkowski_thickness = $material_thickness/2;
  $flat_corner_distance = sqrt(2*pow($minkowski_distance,2)) - $flat_corners;
  difference()
  {
    minkowski()
    {
      intersection()
      {
        cube([$minkowski_distance, $minkowski_distance, $minkowski_thickness], center=true);
        rotate(a=45, v=[0,0,1])
          cube([$flat_corner_distance, $flat_corner_distance, $minkowski_thickness], center=true);
      }
      cylinder(r=$corner_radius, h=$minkowski_thickness, center=true);
    }
    tube_holes();
  }
}


module sliced_plate()
{
  $dist = ($height-$material_thickness)/2;
  translate([0,0,-$dist])
    difference()
    {
      translate([0,0,$dist])
        plate();
      walls();
    }
}

/*
module powersupply()
{
  $h = 29;
  $w = 52;
  $l = 79;
  $drill = 3.5;
  $dist = 55;
  translate([0,0,$h/2])
  {
    cube([$l, $w, $h], center=true);
    for(i=[-1, 1])
      translate([i*$dist/2,0,($h+$material_thickness+$tolerance)/-2])
        cylinder(d=$drill, h=$material_thickness+$tolerance, center=true);
  }
}
*/

module sliced_plate_with_hole()
{
  $minkowski_lenght = $bottom_hole-(2*$corner_radius);
  $minkowski_thickness = $material_thickness/2;
  difference()
  {
    sliced_plate();
    minkowski()
    {
      cube([$minkowski_lenght, $minkowski_lenght, $minkowski_thickness+$tolerance], center=true);
      cylinder(r=$corner_radius, h=$minkowski_thickness, center=true);
    }
  }  
}

module bottom_plate()
{
  $dist = ($height-$material_thickness)/2;
  //Move into actual position
  difference()
  {
    translate([0,0,-$dist])
      sliced_plate_with_hole();
    union()
    {
      screws_and_bolts();
      //translate([-80, -100, -$height/2+$material_thickness])
        //powersupply();
    }
  }
}


/*
module pcb()
{
  $h = 10;
  $w = 70;
  $l = 65;
  $drill = 4;
  $w_dist = 60;
  $l_dist = 55;
  translate([0,0,$h/2])
  {
    cube([$l, $w, $h], center=true);
    //Mounting holes
    for(i=[-1, 1])
      for(j=[-1, 1])
      translate([i*$l_dist/2,j*$w_dist/2,($h+$material_thickness+$tolerance)/-2])
        cylinder(d=$drill, h=$material_thickness+$tolerance, center=true);
    //Hole for 12V supply voltage
    translate([$l/2+10,18.5,($h+$material_thickness+$tolerance)/-2])
      cylinder(d=5.5, h=$material_thickness+$tolerance, center=true);
    //Hole for transducer wires
    for(k=[-10.5, -3.5, 3.5, 10.5])
      translate([$l/2+20,k-7,($h+$material_thickness+$tolerance)/-2])
        cylinder(d=5.5, h=$material_thickness+$tolerance, center=true);
  }  
}
*/


module top_plate()
{
  $dist = ($height-$material_thickness)/2;
  //Move into actual position
  difference()
  {
    translate([0,0,$dist])
      sliced_plate();
    union()
    {
      screws_and_bolts();
      //translate([-80, -80, $height/2])
        //pcb();
    }
  }
}


module wall()
{
  $hole_diameter = 4;
  $hole_distance = 39;
  $vertical_distance = $height/2 - $material_thickness - 6;
  $z_dist = ($height-$material_thickness+$tolerance)/2;
  $cut_length = $wall_length/7;
  difference()
  {
    cube([$wall_length, $material_thickness, $height], center=true);
    union()
    {
      for(i=[-2,0,2])
        for(j=[-1,1])
          translate([i*$cut_length,0,0]) 
            translate([0,0,j*$z_dist])
              cube([$cut_length, $material_thickness+$tolerance, $material_thickness+$tolerance], center=true);
      rotate(v=[1,0,0], a=90)
        cylinder(d=8, h=$material_thickness+$tolerance, center=true);
      for(m=[-$hole_distance/2, $hole_distance/2])
        for(n=[-$vertical_distance, $vertical_distance])
        translate([m, 0, n])
          rotate(v=[1,0,0], a=90)
            cylinder(d=$hole_diameter, h=$material_thickness+$tolerance, center=true);
    }
  }
}

module placed_wall($direction=0)
//0=North, 1=West, 2=South, 3=East 
{
  $dist = ($distance-$tube_diameter - $material_thickness)/2;
  difference()
  {
    rotate(a=90*$direction, v=[0,0,1])
      translate([0,$dist,0])
        wall();
    screws_and_bolts();
  }  
}

module walls()
{
  placed_wall(0);
  placed_wall(1);
  placed_wall(2);
  placed_wall(3);
}

module all()
{
  top_plate();
  bottom_plate();
  walls();
  screws_and_bolts();
}

module flat_walls($spacing=3)
{
  $wall_z_dist = ($distance-$tube_diameter-$material_thickness)/2;
  $wall_x_dist = 0;
  $wall_y_dist = ($distance-$height)/2;
  $wall_y_dist_inc = $height + $spacing;
  //North wall
  translate([$wall_x_dist,$wall_y_dist-0*$wall_y_dist_inc,-$wall_z_dist])
    rotate(v=[1,0,0], a=90)
      placed_wall(0);
  //West wall
  translate([$wall_x_dist,$wall_y_dist-1*$wall_y_dist_inc,-$wall_z_dist])
    rotate(v=[0,1,0], a=90)
      rotate(v=[1,0,0], a=90)
        placed_wall(1);
  //South wall
  translate([$wall_x_dist,$wall_y_dist-2*$wall_y_dist_inc,-$wall_z_dist])
    rotate(v=[1,0,0], a=-90)
      placed_wall(2); 
  //East wall
  translate([$wall_x_dist,$wall_y_dist-3*$wall_y_dist_inc,-$wall_z_dist])
    rotate(v=[0,1,0], a=-90)
      rotate(v=[1,0,0], a=90)
        placed_wall(3);
}

module lasercut_walls($spacing=3)
{
  $fn=100;
  projection(cut=false)
  {
    scale($scale_factor)
    {
      flat_walls($spacing);
    }
  }
}

module flat_top_bottom($spacing=3)
{
  $top_bottom_dist = ($height-$material_thickness)/2;
  //Top plate
  translate([0,0,-$top_bottom_dist])
    top_plate();
  //Bottom plate
  translate([-($distance+$spacing),0,-$top_bottom_dist])
    rotate(v=[1,0,0], a=180)
      bottom_plate();
}

module lasercut_top_bottom($spacing=3)
{
  $fn=100;
  projection(cut=true)
  {
    scale($scale_factor)
    {
      flat_top_bottom($spacing);
    }
  }  
}


//This module contains all parts, fully assembled as a 3D geometry
//Nice to look at but rather useless if you want something you can laser-cut
//all();

//This is a 3D model of the top and bottom part, nicely placed flat next to each other
//flat_top_bottom();

//This is a (scaled-up) 2D projection of the above
//You can export the paths to Adobe Illustrator, for example
//lasercut_top_bottom();

//This is a 3D model of the 4 walls, nicely placed flat next to each other
//flat_walls();

//This is a 2D projection of the above
//You can export the paths to Adobe Illustrator, for example
lasercut_walls();


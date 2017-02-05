
$distance = 300;
$flat_corners = 40;
$corner_radius = 20;
$material_thickness = 5;
$tube_diameter = 16;

$wall_length = 180;
$bottom_hole = 140;
$height = 50;

$tolerance = 0.1;
$fn = 100;
$scale_factor = 72.0 / 25.4;


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


module bottom_plate()
{
  $minkowski_lenght = $bottom_hole-(2*$corner_radius);
  $minkowski_thickness = $material_thickness/2;
  difference()
  {
    sliced_plate();
    union()
    {
      minkowski()
      {
        cube([$minkowski_lenght, $minkowski_lenght, $minkowski_thickness+$tolerance], center=true);
        cylinder(r=$corner_radius, h=$minkowski_thickness, center=true);
      }
      translate([-80, -100, $material_thickness/2])
        powersupply();
    }
  }
}

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


module top_plate()
{
  difference()
  {
    sliced_plate();
    translate([-80, -80, $material_thickness/2])
      pcb();
  }
}


module wall()
{
  $hole_diameter = 4;
  $hole_distance = 34;
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


module walls()
{
  $dist = ($distance-$tube_diameter - $material_thickness)/2;
  for(a=[0, 90, 180, 270])
    rotate(a=a, v=[0,0,1])
      translate([0,$dist,0])
        wall();  
}


module all()
{
  $dist = ($height-$material_thickness)/2;
  translate([0,0,$dist]) top_plate();
  translate([0,0,-$dist]) bottom_plate();
  walls();
}


//all();

module flat()
{
  top_plate();
  translate([-($distance+3),0,0])
    bottom_plate();
  for(i=[0,1,2,3])
    translate([($distance+$wall_length)/2+3,($distance-$height)/2-i*($height+3),0])
      rotate(v=[1,0,0], a=90)
        wall();
}

//wall();



/*
projection(cut=true)
{
  scale($scale_factor)
  {
    flat();
  }
}
*/

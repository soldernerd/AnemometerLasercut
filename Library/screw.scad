
$tolerance=0.01;

module screw_m25($length=18)
{
  //Screw head
  cylinder(h=2.4, d=4.5);
  //Washer
  cylinder(h=0.5, d=5.75);
  //Screw itself
  translate([0,0,-($length-2.4)])
    cylinder(h=$length, d=2.5);
  //Square bolt
  translate([-2.5-$tolerance,-2.5-$tolerance,-($length-3.9)])
    cube([5+2*$tolerance,5+2*$tolerance,1.6]);
}
#version 3.7;

global_settings { assumed_gamma 1.0 }

#include "colors.inc"
#include "textures.inc"
#include "stones2.inc"
// #include "stdcam.inc"

#declare A = clock;   // seems like a bad idea - what are the time units?

// #declare Font="cyrvetic.ttf"
// text{ ttf Font
//    concat("ambient=",str(A,1,2)),0.1,0
//    rotate<0,-5,0> 
//    scale <1.25, 1.5, 4>
//    translate <-3.5, 0, -1>
//    pigment { rgb <1, 0.5, 0.2> }
//    finish { ambient A }
// }




#declare sling_arm_center_height = 2;

#declare hub_x = 0;
#declare hub_y = 0; // is this really more like z (i.e., up from surface?)

light_source { <100,50,100>, White parallel point_at <hub_x, 0, hub_y> }

#declare hub_r = 1.5;
#declare hub_color = Gray50;

#declare sling_arm_length = 400;
#declare sling_arm_base_radius = 1.0;
#declare sling_arm_tip_radius = 0.3;
#declare arm_color = hub_color; 

#declare platform_width = hub_r*1.25;

#declare platform_height = (sling_arm_center_height - sling_arm_base_radius);

#declare hub_height = (sling_arm_center_height + sling_arm_base_radius);

#declare ground_color = Gray20;

#declare strut_r = 0.2;

#declare strut_length = 4*hub_r;


#declare rotation_period = 2; // # of seconds per rotation

#declare av = (2*pi)/rotation_period;   // angular velocity in rad/sec 


global_settings { ambient_light rgb<1,1,1> }    

plane { <0, 1, 0>, 0 pigment {ground_color} }

sphere { <0,0,0> platform_width pigment{Blue} translate <0, hub_r*20, hub_r*20> }


                              
// Would like camera to zoom from height where sling hardly distinguishable
// down to a payload, ride payload out to release toward Earth 

#declare zoom_start = 10;
#declare zoom_inc = -(1/40);
#declare zoom = (clock*zoom_inc+zoom_start);

camera {
  location <zoom*5,zoom*2,zoom*-5>
  look_at <0, sling_arm_center_height, 1>
 }    
 
// crater - for now, height = base of ridge

#declare crater_rim_color = ground_color;

#macro crater(R,h,xloc,zloc)
difference {
  cone {
    <0,0,0>, R+h/2
    <0,h/2,0>, R-h/2
    pigment {crater_rim_color}
  }
  cone {
     <0,h*1.1,0>, R-h/2
     <0,0-0.1,0>, R-h
     pigment {crater_rim_color}
  }
  translate <xloc, 0, zloc>
}
#end

#macro hill (R,h,xloc,zloc) 
sphere {
    <0,h-R,0>, R
    pigment {crater_rim_color}
    translate <xloc, 0, zloc> 
    }
#end

#declare base_clearance = (sling_arm_center_height - sling_arm_base_radius);

crater(2*platform_width, base_clearance/2,   25, -30) 
crater(3*platform_width, base_clearance/1.5, 40,  15)
crater(2.5*platform_width, base_clearance/2, -70, -20)

hill(platform_width*2, base_clearance*0.75, 25, 35) 

#declare rocket_casing_color = Silver;
#declare case_radius = hub_r;
#declare nozzle_height = hub_r;

#declare case_aspect_ratio = 6;

#declare grain_length = case_aspect_ratio*case_radius;
                           
#declare casing_altitude = platform_height+strut_length;  

#declare endcap_radius = case_radius;

#declare motor_length = (2*endcap_radius + grain_length + nozzle_height);
                          
              
#macro rocket_casing(grain_length, case_radius, nozzle_height, nozzle_min, nozzle_max)
   // cylinder + two spheres + cone
union {
   cylinder {
     <0, nozzle_height+case_radius, 0>
     <0, nozzle_height+case_radius+grain_length>
     case_radius
     pigment  {rocket_casing_color} 
     }
   sphere {
     <0, nozzle_height+case_radius, 0> case_radius
     pigment {rocket_casing_color}  
     }
   sphere {
     <0, nozzle_height+case_radius+grain_length, 0> case_radius
     pigment {rocket_casing_color}  
     }
   cone {
     <0, 0, 0>, nozzle_max
     <0, nozzle_height, 0>, nozzle_min
     pigment {rocket_casing_color}
   }   
}
#end

// Turn the solid rocket casing upside down to get the crucible for the furnace    

#macro crucible(grain_length, case_radius, nozzle_height, nozzle_min, nozzle_max, Altitude)
object {
   rocket_casing(grain_length, case_radius, nozzle_height, nozzle_min, nozzle_max)
   rotate <180, 0, 0>           // turn it upside-down
   translate <0, motor_length + Altitude, 0>   // elevate so that former top is at zero height
}
#end
     
// should make all rotating elements one object, with a base cylinder (or box) that doesn't rotate
//   could put sling at <0,0,0>, save all this hub_x/y stuff   

box { 
        <hub_x - platform_width, 0, hub_y - platform_width>
       
        <hub_x + platform_width, sling_arm_center_height - sling_arm_base_radius - nozzle_height, hub_y + platform_width>
        
        pigment { hub_color }
}

// On top of the base:
//    two-armed sling with hub, casing furnace, supported by struts 

#declare strut_r = 0.1;

#declare strut_length = hub_r;

#macro furnace_support_strut(rotation)
  object {
   cylinder {
    // < 0,platform_height + hub_height,0>, < 0, platform_height + hub_height +strut_length , 0>, strut_r  
    // CRUFTY HERE
    < 0,hub_height,0>, < 0, hub_height +strut_length +5, 0>, strut_r
    pigment {Silver}
    translate < hub_r, 0, 0>
   }
   rotate <0,rotation,0>
  }
#end


union {                                          
  // hub rotation not noticeable unless hub textured enough and camera close enough to hub 
 
  crucible(grain_length, hub_r, nozzle_height, 0.5*hub_r, hub_r, casing_altitude)
  
  furnace_support_strut(0)
  furnace_support_strut(90) 
  furnace_support_strut(180)
  furnace_support_strut(270)

  cylinder
    {   
        <0, 0,                                                0>,
        <0, sling_arm_center_height + sling_arm_base_radius,  0>,
        hub_r                                                  
        pigment { hub_color }
    }

  // Two balanced arms of the sling
  //   Assuming negligible droop for now 

  cone                            
    {
        <0 + sling_arm_length,  sling_arm_center_height, 0>, sling_arm_tip_radius
        <0,                     sling_arm_center_height, 0>, sling_arm_base_radius
        pigment { arm_color }
    } 
  cone
    {
        <0 - sling_arm_length,  sling_arm_center_height, 0>, sling_arm_tip_radius
        <0,                     sling_arm_center_height, 0>, sling_arm_base_radius 
        pigment { arm_color }
    }
    
  rotate <0, A, 0> 
    
  translate <hub_x, 0, hub_y>   // not liking this coord system; rectify soon 
}


// #declare R = 0.4;
// sphere { <-1.0, 0.4, -3.0>, R
//    pigment { Gray }
//    finish { ambient A }
// }
                        

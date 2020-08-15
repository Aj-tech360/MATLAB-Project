function distance_takeoff_feet = caldistft(a_vel_off_ms, a_int_xvel, a_acc, a_int_xpos)
%
%

%Benjamin Sites

%calculate time to reach takeoff speed
a_time_vel = (a_vel_off_ms - a_int_xvel) / a_acc;

%calculate distance needed to takeoff in meters
distance_takeoff_meters = a_int_xpos + a_time_vel * a_int_xvel + 1/2 * a_acc * a_time_vel^2;

%convert distance to takeoff to feet
distance_takeoff_feet = distance_takeoff_meters * 3.28084;
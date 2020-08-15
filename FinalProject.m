%{
Benjamin Sites
Seciton 3
Title: Final Project - Calcuate and Plot Plane Takeoff
%}

%clean up commands
clear;
clc;
close all;
format compact;
rng shuffle;


%---------_-While loop for user restarting-----------
user_repeat = 'Y'; %set intial condition for user repeat so it will go to the while loop
while user_repeat == 'Y'
    close all; 
    
    %-----------Importing Data and Asking User Questions-----------
    %welcome message 
    fprintf('\tChoose your airport and runway to see if your plan can take off.\n');

    %import aircraft data
    [~, ~, raw_a] = xlsread('AircraftData.xlsx');                                                                                                                                   %<SM:READ>

    %import airport data
    [~, ~, raw_b] = xlsread('AirportData.xlsx');

    %backup and delete aircraft table titles 
    orginal_aircraft_table_titles = raw_a(1, :);                                                                                                                                     %<SM: REF>
    raw_a(1, :) = [ ];                                                                                                                                                                            %<SM:DIM>
    
    %set intial condition for while loop
    correct_inputs = 'N';
    while correct_inputs == 'N'
        %print aircraft table 
        num_u_planes = length(raw_a(:, 1));
        col1_a = num2cell(1:num_u_planes);
        planes = raw_a(:, 1);
        aircraft_table = [col1_a; planes'];
        fprintf('%d - %s\n', aircraft_table{:});

        %ask user for plane 
        plane_type = input(sprintf('What plane are you flying today? (1 to %d) \n --> ', num_u_planes));                                                     %<SM:STRING>
        while isempty(plane_type) | plane_type ~= 1: num_u_planes                                                                                                          %<SM:WHILE>
            plane_type = input(sprintf('ERROR: 1-%d only: ', num_u_planes));
        end

        %backup airport table titles 
        orginal_airport_table_titles = raw_b(1, :);

        %list all unique airports
        all_u_airports = unique(raw_b(2:end, 1));

        %number of unique airports
        num_u_airports = length(all_u_airports);

        %print airports and ask user for airport
        row1_b = num2cell(1:num_u_airports);
        airports_table = [row1_b ; all_u_airports'];
        fprintf('\n');
        fprintf('%d - %s\n', airports_table{:});
        airport_selection = input(sprintf('What airport are you flying from? (1 to %d)\n --> ',num_u_airports));
        while isempty(airport_selection) | airport_selection ~= 1:num_u_airports                                                                                            %<SM:BOOCON>
            airport_selection = input(sprintf('ERROR: 1 to %d only: ',num_u_airports));
        end

        %filiter runways to selected airport
        airport = airports_table{2, airport_selection};
        raw_b(1,:) = [ ];
        col1_b = raw_b(:, 1);
        filtered_runways = raw_b(strcmp(col1_b, airport), :);

        %print and ask user for runway
        runway_lengths = filtered_runways(:,4);
        uni_runways = filtered_runways(:, 3);
        num_uni_runways = length(uni_runways);
        row1_r = num2cell(1:num_uni_runways);
        fprintf('\n');
        runways_table = [row1_r ; uni_runways'];
        fprintf('%d: %s\n', runways_table{:})
        air_runway = input(sprintf('What runway are you on? (1 to %d)\n --> ',num_uni_runways));
        while isempty(air_runway) | air_runway ~= 1:num_uni_runways
            air_runway = input(sprintf('ERROR: 1 to %d only: ',num_uni_runways));
        end

        %ask user if above info is correct
        correct_inputs = input('\nIs the information you entered above correct? [Y or N]: ','s');
        while isempty(correct_inputs) || correct_inputs ~= 'Y' && correct_inputs ~= 'N'
            correct_inputs = input('Error: Y or N only: ','s');
        end

    end

    %clean up command window
    clc;
    
    
    %-----------Plotting Intial Conditions-----------
    %find user's runway length
    user_runway_length = cell2mat(runway_lengths(air_runway, 1));

    %plot runway
    runway_xs = [0, user_runway_length, user_runway_length, 0, 0];
    runway_ys = [0, 0, 1, 1, 0];
    plot(runway_xs,runway_ys, 'k', 'linewidth', 3);                                                                                                                                   %<SM:PLOT>
    axis equal off;
    hold on;
    title('Aircraft Path from Runway to Climb');
    xlabel('Distance(ft)/Time(sec)');
    ylabel('Distance(ft)');
    
    %plot building
    rand_num_buld1 = randi([300, 350]);                                                                                                                                                   %<SM:RANDGEN>
    rand_num_buld2 = randi([400, 500]);
    building_base1 = user_runway_length + rand_num_buld1;                                                                                                                %<SM:RANDUSE>
    building_base2 = user_runway_length + rand_num_buld2;
    building_xs = [building_base1, building_base2, building_base2, building_base1, building_base1];
    building_height = randi([600, 700]);
    building_ys = [0, 0, building_height, building_height, 0];
    fill(building_xs, building_ys, 'b');
    
    
    %-----------Aircraft Calculations-----------  
    %give aircraft initial conditions
    a_int_xpos = 0; %ft
    a_int_ypos = 0; %ft
    a_int_xvel = 0; %ft/s
    a_int_yvel = 0; %ft/s
    a_acc = (rand + 1) * 3.28084;       %ft/s^2                                                                                                                                         
    ay_acc = 0; %ft/s^2

    %set takeoff velocity (mph)
    a_vel_off_mph = cell2mat(raw_a(plane_type, 2));

    %convert to m/s
    a_vel_off_ms = a_vel_off_mph / 2.237;

    %convert to feet/sec
    a_vel_off_fps = a_vel_off_mph * 5280 / 3600; 

    %set climbing angles
    c_angle1 = cell2mat(raw_a(plane_type, 3));
    c_angle2 = cell2mat(raw_a(plane_type, 4));

    %set change in climbing angles (degrees/sec) 
    climb_ang_dt = 2; 

    %time at angle 1
    c_angle1_time = 3;
    
    %find time to get to desired climbing angle 
    time_ang1 = c_angle1 / climb_ang_dt;
    time_ang2 = c_angle2 / climb_ang_dt; 
    
    %calcuate distance to takeoff in feet
    distance_takeoff_feet = caldistft(a_vel_off_ms, a_int_xvel, a_acc, a_int_xpos);                                                                               %<SM:PDF > <SM:PDF_PARAM> <SM:PDF_RETURN>

    %calculate time to takeoff
    takeoff_time = a_vel_off_fps / a_acc;

    %set time range for plots
    time_at_ang1 = 0;  
    time_at_ang2 = 0;
    time_plot_max = 25;
    
    %time step for whiles and fors
    time_step = 0.5;
    
    %find angle step
    th_ang1 = 0;
    th_ang2 = (c_angle2 - c_angle1); 
    while1_repeats = time_ang1 / time_step;
    while2_repeats = time_ang2 / time_step;
    th_ang1_step = c_angle1 / while1_repeats;
    th_ang2_step = th_ang2 / while2_repeats; 
    
    
    %-----------Plotting Aircraft Path-----------
    %plot path on runway(4)
    aircraft_runway_xs = 0:distance_takeoff_feet;
    aircraft_runway_size = ones(size(aircraft_runway_xs)) * 0;                                                                                                               
    a_run = plot(aircraft_runway_xs, aircraft_runway_size, '--', 'linewidth', 2);
    set(a_run, 'Color','yellow');                                                                                                                             
    
    %plot first part of takeoff
    while (time_at_ang1 <= time_ang1 && th_ang1 <= c_angle1)
        %find  x and y velocities for angle 1
        ang1_int_xvel = a_vel_off_fps * cosd(th_ang1);
        ang1_int_yvel = a_vel_off_fps * sind(th_ang1);
        
        %find x and y acceleraitons for angle 1
        x_acc1 = a_acc * cosd(th_ang1);
        y_acc1 = a_acc * sind(th_ang1);

        %equations for plane's flight path during angle 1
        flight_xs_ang1 = distance_takeoff_feet + ang1_int_xvel * time_at_ang1 + 1/2 * x_acc1 * time_at_ang1^2;
        flight_ys_ang1 = a_int_ypos + ang1_int_yvel * time_at_ang1 +  1/2 * y_acc1 * time_at_ang1^2;

        %plot aircraft  postion for angle 2
        plot(flight_xs_ang1, flight_ys_ang1, 'gx', 'linewidth', 2);
        
        %calculate new time and angle running total 
        time_at_ang1 = time_at_ang1 + time_step;                                                                                                                                         %<SM:RTOTAL>
        th_ang1 = th_ang1 + th_ang1_step;              
    end
    
    %plot in between angles
    for time_between = 0:time_step:c_angle1_time
        flight_xs_between = flight_xs_ang1 + ang1_int_xvel * time_between + 1/2 * x_acc1 * time_between^2;
        flight_ys_between = flight_ys_ang1 + ang1_int_yvel * time_between +  1/2 * y_acc1 * time_between^2;
        plot(flight_xs_between, flight_ys_between, 'gx', 'linewidth', 2);
    end

    %plot second part of takeoff
    while (time_at_ang2 <= time_ang2 && th_ang2 <= c_angle1)
        %find  x and y velocities for angle 2
        ang2_int_xvel = a_vel_off_fps * cosd(th_ang2);
        ang2_int_yvel = a_vel_off_fps * sind(th_ang2);
        
        %find x and y acceleraitons for angle 2
        x_acc2 = a_acc * cosd(th_ang2);
        y_acc2 = a_acc * sind(th_ang2);
        
        %equations for plane's flight path during angle 2
        flight_xs_ang2 = flight_xs_between + ang2_int_xvel * time_at_ang2 + 1/2 * x_acc1 * time_at_ang2.^2;
        flight_ys_ang2 = flight_ys_between + ang2_int_yvel * time_at_ang2 +  1/2 * y_acc1 * time_at_ang2.^2;

        %plot aircraft postion for angle 2
        plot(flight_xs_ang2, flight_ys_ang2, 'gx', 'linewidth', 2);
        
        %calculate new time and angle running total 
        time_at_ang2 = time_at_ang2 + time_step;
        th_ang2 = th_ang2 + th_ang2_step;
    end

    %equations for plane's flight path after angle 2
    for time_plot3 = 0:time_step:time_plot_max %time_plot_max 
        flight_xs_af_ang2 = flight_xs_ang2 + ang2_int_xvel * time_plot3 + 1/2 * x_acc2 * time_plot3^2;
        flight_ys_af_ang2 = flight_ys_ang2 + ang2_int_yvel * time_plot3 +  1/2 * y_acc2 * time_plot3^2;
        plot(flight_xs_af_ang2, flight_ys_af_ang2,  'gx', 'linewidth', 2);
    end
    
    %change auto zoom
    graph_x_max = building_base2 + 100;
    graph_y_max =  flight_ys_af_ang2 +100;
    axis([0, graph_x_max, 0, graph_y_max]);
    
    %add legend
    %legend('runway', 'building', 'runway path', 'flight path', 'location', 'southoutside'); 
    
    
    %-----------Determine Aircraft's Fate-----------
    %calculate plane height at building
    height_at_building = plane_h2(user_runway_length, x_acc1, x_acc2, building_base1, distance_takeoff_feet, y_acc1, y_acc2, ang1_int_xvel, ang1_int_yvel, ang2_int_xvel, flight_xs_between, ang2_int_yvel, flight_ys_ang1, flight_ys_ang2); 
    
    %define if plane takes off or runs out of runway
    if distance_takeoff_feet < user_runway_length                                                                                                                                %<SM:IF>
        takeoff_suc = 'Y';
    else 
        takeoff_suc = 'N';
    end

    %define if plane clears building
    if height_at_building <= building_height                                                                                                                                           %<SM:RELCON>
        plane_clears = 'N';
        
        %play sound for crash
        crash_sound = audioread('planeCrash.wav');                                                                                                                                        %<SM:NEWFUN>
        sound(crash_sound);
        
        %plot collision (1)
        theta = linspace(0, 2*pi);
        time_pause = 0.25;
        for k = 120:0.5:150                                                                                                                                                                              %<SM:FOR>
            %define r for parametric equation
            r = k * (1 + 1/10 * cos(18 * theta));
    
            %parametric equations for explosion
            explosion_xs = r .* cos(theta) + building_base1;
            explosion_ys = r .* sin(theta) + height_at_building;
    
            %plot explosion
            plot(explosion_xs, explosion_ys, 'r');
            
            pause(time_pause);    
        end
        
    else 
        plane_clears = 'Y';
    end

    %determine if plane will fly or not
    if plane_clears == 'Y' &&  takeoff_suc == 'Y'
         fprintf('Your plane will fly. It can successfully takeoff and clear the building.\n\n');

        %find rows for information table
        headers_final = [orginal_airport_table_titles(1), orginal_airport_table_titles(3), orginal_aircraft_table_titles(1:2),'Takeoff Distance (ft)'];
        pilot_info = [airport, runways_table{2, air_runway}, aircraft_table{2, plane_type}, num2cell(a_vel_off_mph), num2cell(distance_takeoff_feet)];

        %print table with all data
        fprintf('%-27s  %-9s  %-10s  %-3s  %-21s', headers_final{:});
        fprintf('\n--------------------------------------------------------------------------------------------------------------\n');
        fprintf('%-27s  %-9s  %-10s  %-3.0f  %-21.1f', pilot_info{:});

    else
        if takeoff_suc == 'N'                                                                                                                                                                         %<SM:NEST>
            %tell user the distance they need to takeoff
            cel_distance_takeoff = ceil(roun_distance_takeoff);
            fprintf('Your plane will crash. It cannot successfully takeoff. You need at least %d feet to take off and the runway is only %d feet\n'...
            , cel_distance_takeoff, runway_length);
        elseif plane_clears == 'N'
            %tell user they wont clear the building 
            fprintf('Your plane will crash. It cannot successfully clear the building. ');
        end
    end
       
    
    %-----------User Restart-----------
    %ask user if they would like to repeat
        user_repeat = input('\n\nWould you like to repeat the code? [Y or N]: ','s');
        while isempty(user_repeat) || user_repeat ~= 'Y' && user_repeat ~= 'N'
            user_repeat = input('Error: Y or N only: ','s');
        end
        
end

  fprintf('\n\nHave a good flight!\n');
 


%SOURCES
%{
1: https://community.wolfram.com/groups/-/m/t/512225?sortMsg=Replies 
    Used to get parametric equation for explosion

2: https://www.bangaloreaviation.com/2009/05/typical-takeoff-and-climb-angles-of-all.html (Decesh Agarwal)
    Used to get data for climbing angles for aircraft data file

3: http://www.aerospaceweb.org/question/performance/q0088.shtml 
    Used to get data for take off velocity for aircraft data

4. https://www.mathworks.com/matlabcentral/answers/16401-plotting-a-line-x-constant
    Used to reference how to plot line for aircraft path on runway
%}






  
  
  
  
  
  
 










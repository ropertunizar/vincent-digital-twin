function [pairing_table, error_table] = findmindistance_table (curve1, curve2, max_search_radius, calc_initial, calc_middle, calc_final)

% initialize pairing 1-1, 2-2, ...
total_length = length(curve1);
initial_ordering= (1:1:total_length)';

pairing_table=zeros(total_length,2);
error_table=zeros(total_length,1);
%pairing_table(:,1:2) = [initial_ordering, initial_ordering]; %initialize with initial ordering
pairing_table(:,1) = initial_ordering;

initial_offset = 0;
%middle_counter = max_search_radius; %  SURE??
%end_counter = total_length - max_search_radius  ; %initialize end_counter


%starting point
% search
fprintf(   '- search start -\n');
for p = 1:total_length

    min_dist = 999; %initialize min_dist
    
    % 1) MIDDLE PART (BIGGER ONE), normal search backwards and forwards
    if (p > max_search_radius) &&  (p <= total_length-max_search_radius) && (calc_middle)
        
        %fprintf("\n---SEARCHING FOR P1(%i)\n", p);
        %min_dist_index_2 = p; %initialize with same index 
        
        p1 = curve1 (p,:); %THE REF CURVE IS 1
        %fprintf("-p1=(%f, %f) \n", p1);

        search_area = (2*max_search_radius+1);
        min_dist_index_2_relative = 1;

        for i=1:search_area
           
            offset_middle = i - (max_search_radius+1);
            p2 = curve2 (p+offset_middle,:);
            
            %fprintf("-p2=(%f, %f) \n", p2);

            %fprintf("-searching for i=%i\n", i);
            [min_dist, min_dist_index_2_relative ] = walk_vector(p1,p2,i, min_dist, min_dist_index_2_relative);
        end

        offset_mid = min_dist_index_2_relative - (max_search_radius+1); 
        min_dist_index_2 = p + offset_mid; %to compensate offset

        %min_dist_index_2 = p + min_dist_index_2_relative + middle_counter; %to compensate offset
        %fprintf("---pairing completed\n"); 
        %fprintf("--- P1(%i)<->P2(%i)\n\n", p,min_dist_index_2 );  
        
        pairing_table(p,2) = min_dist_index_2; %assign index value to corresponding p
        error_table(p,1) = min_dist;
        
        %middle_counter = middle_counter+1; %increase middle counter


    else
        % 2) INITIAL PART 
        if (p <= max_search_radius) && (calc_initial)

            %fprintf("\n---SEARCHING FOR P1(%i)\n", p);
            %min_dist_index_2_start = p; %initialize with same index     
            extra_back = p; %to search "backwards" as the p grows

            if extra_back > total_length-max_search_radius
                extra_back = total_length-max_search_radius;
            end

            p1 = curve1 (p,:); %THE REF CURVE IS THE DESIRED
            %fprintf("-p1=(%f, %f) \n\n", p1);
            
            min_dist_index_2_relative = 1; %always starts at 1...

           for i = 1:max_search_radius + extra_back

                %fprintf("-searching for i=%i\n", i);
                
                p2 = curve2 (i,:);
                %fprintf("-p2=(%f, %f) \n", p2);

                [min_dist, min_dist_index_2_relative ] = walk_vector(p1,p2,i, min_dist, min_dist_index_2_relative);
    

           end
           %fprintf("---pairing completed\n"); 
           %fprintf("--- P1(%i)<->P2(%i)\n\n", p,min_dist_index_2_relative );  

           pairing_table(p,2) = min_dist_index_2_relative + initial_offset; %assign index value to corresponding p, initial_offset=0 always as we are at the beginning
           error_table(p,1) = min_dist;
         else
                
             % 3)FINAL PART
             if (p>total_length-max_search_radius) && (calc_final==true)

               
                %fprintf("\n---SEARCHING FOR P1(%i)\n", p);
                %min_dist_index_2 = p; %initialize with same index 

                extra_remainder = total_length-p+1; %to search "backwards" as the p grows    
                p1 = curve1 (p,:); %THE REF CURVE IS 1
                %fprintf("-p1=(%f, %f) \n", p1);
        
                
        
     

                min_dist_index_2_relative = 1;
                
               for k =1:max_search_radius + extra_remainder
    
                    %fprintf("-searching for i=%i\n", i);
                    offset2 = k - (max_search_radius+1);
                    p2 = curve2 (p+offset2,:);
                    %fprintf("-p2=(%f, %f) \n", p2);
    
                    [min_dist, min_dist_index_2_relative ] = walk_vector(p1,p2,k, min_dist, min_dist_index_2_relative);
        
    
               end
               %fprintf("pairing completed\n\n"); 

               offset_end = min_dist_index_2_relative - (max_search_radius+1); 
               min_dist_index_2 = p + offset_end; %to compensate offset

               %fprintf("---pairing completed\n"); 
               %fprintf("--- P1(%i)<->P2(%i)\n\n", p,min_dist_index_2 );  
               
               pairing_table(p,2) = min_dist_index_2; %assign index value to corresponding p
               error_table(p,1) = min_dist; 

               %pairing_table(p,2) = min_dist_index_2; %assign index value to corresponding p
               %end_counter = end_counter+1; %increase middle counter





             
             end
             
         end
        
    end %main if
        
    
end



fprintf(   '- search ended -\n');




end

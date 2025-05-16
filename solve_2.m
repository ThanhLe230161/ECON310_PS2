%% File Info.

%{

    solve.m
    -------
    This code solves the model.

%}

%% Solve class.

classdef solve_2
    methods(Static)
        %% Solve the model using BI. 
        
        function sol = lc(par)            
            %% Structure array for model solution.
            
            sol = struct();
            
            %% Model parameters, grids and functions.
            
            T = par.TT; % Last period of life.
            tr = par.tr; % First year of retirement.

            beta = par.beta; % Discount factor.

            alen = par.alen; % Grid size for a.
            agrid = par.agrid; % Grid for a (state and choice).
            agrid = agrid(:);  % Force once at beginning!


            ylen = par.ylen; % Grid size for y.
            ygrid = par.ygrid; % Grid for y.
            pmat = par.pmat; % Transition matrix for y.

            r = par.r; % Real interest rate.
            kappa = par.kappa; % Share of income as pension.

            %% Backward induction.
            
            v1 = nan(alen,T,ylen); % Container for V.
            a1 = nan(alen,T,ylen); % Container for a'.
            c1 = nan(alen,T,ylen); % Container for c'.

            amat = repmat(agrid,1,ylen);
            ymat = repmat(ygrid,alen,1);
            
            fprintf('------------Solving from the Last Period of Life.------------\n\n')
            
            for age = 1:T % Start in the last period and iterate backward.
                
                if T-age+1 == T % Last period of life.

                    c1(:,T,:) = amat + kappa*ymat; % Consume everything.
                    a1(:,T,:) = 0.0; % Save nothing.
                    v1(:,T,:) = model_2.utility(c1(:,T,:),par); % Terminal value function.

                else % All other periods.
    
                    for i = 1:ylen % Loop over the y-states.

                        if T-age+1 >= tr % Workers get a salary; retirees get a pension proportional to last drawn salary.
                            t = T - age + 1;     
                            yt = kappa * par.G(t) * ygrid(i);
                            ev = v1(:,T-age+2,i);
                        else
                            yt = ygrid(i);
                            ev = squeeze(v1(:,T-age+2,:))*pmat(i,:)';
                        end
        
                        for p = 1:alen % Loop over the a-states.
                            
                            % Consumption
                            resources = (1+r)*agrid(p) + yt;  % scalar
                            ct = resources - agrid;  % <-- Expand scalar into full vector
                            ct(ct<0.0) = 0.0;                  % No negative consumption allowed
    
                            % Solve the maximization problem.
                            vall = model_2.utility(ct,par) + beta*ev; % Compute the value function for each choice of a', given a.
                            vall(ct<=0.0) = -inf; % Set the value function to negative infinity when c <= 0.
                            [vmax,ind] = max(vall); % Maximize: vmax is the maximized value function; ind is where it is in the grid.
                            
                            % Store values.
                            v1(p,T-age+1,i) = vmax; % Maximized v.
                            c1(p,T-age+1,i) = ct(ind); % Optimal c'.
                            a1(p,T-age+1,i) = agrid(ind); % Optimal a'.
       
                        end

                    end
                    
                end

                % Print counter.
                if mod(T-age+1,5) == 0
                    fprintf('Age: %d.\n',T-age+1)
                end

            end
            
            fprintf('------------Life Cycle Problem Solved.------------\n')
            
            %% Macro variables, value, and policy functions.
            
            sol.c = c1; % Consumption policy function.
            sol.a = a1; % Saving policy function.
            sol.v = v1; % Value function.

            %sol.c = flip(sol.c,2);
            %sol.a = flip(sol.a,2);
            
        end
        
    end
end
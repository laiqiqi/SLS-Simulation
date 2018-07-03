function [T,maxT, it] = computateHeatEquation2D(tFinal, q_w, u0, T_air, T_bed)
    % [T] = computateHeatEquation2D(tFinal)
    %
    % Bachelor thesis equation number: ()
    % 
    %
    %
    
    %% Parameters
    
    % Get thermal parameters
    thermalParameter = getThermalParameter();
    
    a = computateThermalDiffusivity(184.3) * 10^5;
    Lx = thermalParameter.lengthOfDomainInX;
    Ly = thermalParameter.lengthOfDomainInY;
    nx = thermalParameter.numberOfNodesInX;
    ny = thermalParameter.numberOfNodesInY;
    dx = Lx/(nx-1);
    dy = Ly/(ny-1);
    Dx = a/dx^2;
    Dy = a/dy^2;
    
    rho =  computateDensity(184.3);
    c_p = computateHeatCapacity(184.3);
    
    % Build Numerical Mesh
    [x,y] = meshgrid(0:dx:Lx,0:dy:Ly);

    % Set Initial time step
    dt0 = 1/(2*a*(1/dx^2+1/dy^2)); % stability condition
    
    if dt0 > 1 * 10^-3
        dt0 = 1 * 10^-4;
    else
        dt0 = dt0;
    end
    
    %% Solver Loop 
    % load initial conditions
    t=dt0; it=0; u=u0; dt=dt0;
    
    q = zeros(nx,ny);
    q(nx-1,:) = q_w/thermalParameter.layerThickness;
    
    maxT = 0;
    
    iter = tFinal / dt0;
    iterA = iter / nx;
    
    while t < tFinal
         
        % RK stages
        uo=u;
        q(nx-1:nx,:) = 0;
        q(nx-1:nx,it+4) = q_w/thermalParameter.layerThickness;
        
         % forward euler solver
         u = finiteDifferenceMethod2D(uo,nx,ny,Dx,Dy,dt,q,rho,c_p);
         T = u;
         
         % set BCs
         u(1,:) = T_bed;
         u(:,1) = T_bed; u(:,ny) = T_bed;
         
         if q_w == 0
             u(nx,:) = T_air;
         else
             u(nx,:) = uo(nx-1,:);
         end
         
         % compute time step
         if t + dt > tFinal
             dt = tFinal - t; 
         end
         
         % Update iteration counter and time
         it = it + 1; t = t + dt;
         
         if maxT < max(max(T))
             maxT = max(max(T));
         else
             maxT = maxT;
         end
         
         % plot solution
         %{
         if mod(it,100)
             figure(1)
             hold on;
             surf(x,y,u-273.15);
             view(0,90);
             titlePlot = ['Elapsed time: ' num2str(t) ' s'];
             title(titlePlot);
             cb = colorbar;
             ylabel(cb, 'Temperatur �C');
             %axis([0,L,0,W,-1,1]);
             drawnow;
         end
         %}
    end
    %{
    fig = figure(1);
    surf(x,y,u-273.15);
    view(0,90);
    titlePlot = ['Elapsed time: ' num2str(t) ' s'];
    title(titlePlot);
    xlabel('x [m]');
    ylabel('y [m]');
    zlabel('Temperatur �C');
    cb = colorbar;
    ylabel(cb, 'Temperatur �C');
    %orient(fig,'landscape');
    %print(fig,'-bestfit','Test','-dpdf','-r0');
    %}
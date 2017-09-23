%% Moonlander Example
%
% Arthur Bryson - Dynamic Optimization
%
%% Problem description
% Example about landing an object.

% Copyright (c) 2007-2008 by Tomlab Optimization Inc.

%% Problem setup
toms t
toms t_f
p = tomPhase('p', t, 0, t_f, 60);
setPhase(p);

tomStates altitude speed
tomControls thrust

% Initial guess
x0 = {t_f == 1.5
    icollocate({
    altitude == 0
    speed == 0
               })
    collocate(thrust == 0)};

% Box constraints
cbox = {
    0  <= t_f                   <= 1000
    -20  <= icollocate(altitude) <= 20
    -20  <= icollocate(speed)    <= 20
    0  <= collocate(thrust)    <= 3};

% Boundary constraints
cbnd = {initial({altitude == 10; speed == -2})
    final({altitude == 0; speed == 0})};

% ODEs and path constraints
gravity         = 1.5;
ceq = collocate({
    dot(altitude) == speed
    dot(speed)    == -gravity + thrust});

% Objective
objective = integrate(thrust);

%% Solve the problem
options = struct;
options.name = 'Moon Lander';
options.solver= 'knitro';
options.PriLevOpt = 1;
%options.ALG = 3;
%options.derivatives = 'automatic';
solution = ezsolve(objective, {cbox, cbnd, ceq}, x0, options);

% sampled solution
t_plot  = linspace(0, subs(t_f, solution), 100);
altitude_plot = subs(atPoints(t_plot, altitude),solution);
speed_plot  = subs(atPoints(t_plot, speed),solution);
thrust_plot  = subs(atPoints(t_plot, thrust),solution);

% original solution
t  = subs(collocate(t),solution);
altitude = subs(collocate(altitude),solution);
speed  = subs(collocate(speed),solution);
thrust = subs(collocate(thrust),solution);

% optimal solution
v0 = -2;
h0 = 10;
ts = 1.4154;
tf_opt = 4.1641;
pts = 100;

t_opt = linspace(0,tf_opt,pts)';

h_opt = zeros(pts,1); v_opt = zeros(pts,1); u_opt = zeros(pts,1);

for i = 1:1:pts
  [h, v, u] = optimal_solution(t_opt(i),v0,h0,ts);
  h_opt(i) = h; v_opt(i) = v; u_opt(i) = u;
end

%% Plot result
figure(1);clf
title('Moon Lander');

subplot(3,1,1)
plot(t_opt,h_opt,'k-','linewidth',2.5)
hold on
plot(t_plot,altitude_plot,'r--','linewidth',2);
hold on
plot(t,altitude,'*');
xlabel('time (s)')
ylabel('altitude ')
legend('optimal','ploy.','coloc. pts')

subplot(3,1,2)
plot(t_opt,v_opt,'k-','linewidth',2.5)
hold on
plot(t_plot,speed_plot,'r--','linewidth',2);
hold on
plot(t,speed,'*');
xlabel('time (s)')
ylabel('speed')
legend('optimal','ploy.','coloc. pts')

subplot(3,1,3)
plot(t_opt,u_opt,'k-','linewidth',2.5)
hold on
plot(t_plot,thrust_plot,'r--','linewidth',2);
hold on
plot(t,thrust,'*')
xlabel('time (s)')
ylabel('thrust')
legend('optimal','ploy.','coloc. pts')


%% Save results


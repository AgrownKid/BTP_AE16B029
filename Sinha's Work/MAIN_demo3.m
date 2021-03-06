% MAIN.m
% 
% Sloves a linear sytem using shifted chebyshev polynomial
% 
% INPUT: "problem" -- struct with fields:
% 
%     Input Notes: square braces show the size: [a,b] = size()
%                  || || : gives additional explaination
%
%           m = scalar = number of terms in the shifted chebyshev expansion
%           n = scalar = number of states
%                        
%           ||   Given a system,             xdot = A(t)x          ||
%           ||   A(t) acn be expressed as => A(t) = A' + A''(t)    ||
%           ||   This is done to improve the speed of solving      ||
%           ||   A' = time ivariant part of A(t)                   ||
%           ||   A''(t) = time variant part of A(t)                ||
% 
%           apeeriodic_mat = [n,n] = time invariant part of A(t) matrix
%           periodic_mat = [n,n] cell = time variant part of A(t) matrix
%           
%           || Enter the aperiodic_mat as a [n,n] matrix            || 
%           || Enter the periodic_mat as a [n,n] cell               ||
%
%           || For Example if , xdot  = [cos(t), sin(t);            ||
%           ||                           c+sin(t), d] x             ||
%           || Then periodic_mat = {@(t) cos(t), @(t) sin(t);       ||
%           ||                      @(t) sin(t), @(t) 0}            ||
%           || Then aperiodic_mat = [0,0;                           || 
%           ||                       c,d]                           ||
%
%           initialcond = [n,1] = set of initial condidtions of all states
%           ti = scalar = initial time  
%           tf = scalar = final time 
%           method = string = "firstkind" or "secondkind"
%                              command to use shifted chebyshe polynomials 
%                              of firstkind or second kind for solving
% 
% 
% 
% OUTPUT: "soln" -- struct with fields
%
%           StateFunc = @(t) = Matlab function of State for time interval [ti,tf]
%           PhiFunc = @(t) = Matlab function of Phi (the state transition matrix)
%                               ***vaild only in interval [ti,tf]***
%           StateExpression = [n,1] symbolic  = Symbolic Expression of State
%           PhiExpression = [n,n] symbolic = Symbolic Expression of Phi
%           StateExpnCoeffs = [mn,1] = State Expansion Coefficients
%           phiExpnCoeffs = [mn,n] = Phi Expansion Coefficients
%
%       Output Notes: The function PhiFunc(t) = will not work for array
%                     inputs of time t. This has something to do with
%                     MATLAB inability to construct array of independent 
%                     functions in 2018a. In case, if in next version it is
%                     possible to do it, then its fine. 
%                     For now, if the user wants to analyze all elements of
%                     Phi i.e Phi(1,1), Phi(1,2) etc it recommended to use
%                     the PhiExpression to extract seperate expansion of each
%                     element i.e element11 = PhiExpression(1,1) ,
%                     element12 = PhiExpresson(1,2) and then convert each
%                     element to a MATLAB function using 
%                     element11function = matlabFunction(element11)

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%                               Inputs                                    %
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
clc; clear all;

% Demo Problem 3
% A(t) = [cos(t), sin(t);
%           -sin(t), cos(t)]
%
% aperiodic_mat = [0, 1;
%                   0, 0]
%
% periodic_mat = {@(t) cos(t), @(t) sin(t);
%                   @(t) -sin(t), @(t) cos(t)}


problem.m = 13;
problem.n = 2;
problem.aperiodic_mat = [0, 0;...
                         0, 0]; 
problem.periodic_mat = {@(t)cos(t),@(t) sin(t);...
                        @(t) -sin(t),@(t) cos(t)};
problem.initialcond = ones(2,1);
problem.ti = 0;
problem.tf = 2*pi;
problem.method = "firstkind";

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%                  Solution as Function Handle in Matlab                  %
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

soln = shiftedchebexpansion(problem);

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%                Plots [comparing ode45 solution and this method]
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
set(groot,'DefaultAxesColorOrder',[0 0 1; 1 0 0; 0 0 0],'DefaultLineLineWidth',2);
set(groot,'DefaultAxesFontSize',20,'defaultAxesFontName', 'Times','defaultTextFontName', 'Times')

% Ode45 State
[t_ode45,State_ode45] = ode45(@(t,X) system_for_ode(t,X),[problem.ti problem.tf],problem.initialcond);

% Chebyshev State 
State_Cheb = soln.StateFunc(t_ode45');

%%%% Plot
figure;
switch problem.method
    case "firstkind"
for i = 1:1:problem.n
        subplot(2,1,i)
        hold on
        grid on
        plot(t_ode45,State_Cheb(i,:),'ro','LineWidth',2);
        plot(t_ode45,State_ode45(:,i),'k--','LineWidth',2);
        legend("Shifted Cheb 1st kind","ODE45")
        title("state " + i)
        xlabel('time');
        ylabel('Val')
end

    case "secondkind"
for i = 1:1:problem.n
        subplot(2,1,i)
        hold on
        grid on
        plot(t_ode45,State_Cheb(i,:),'ro','LineWidth',2);
        plot(t_ode45,State_ode45(:,i),'k--','LineWidth',2);
        legend("Shifted Cheb 2nd kind","ODE45")
        title("state " + i)
        xlabel('time');
        ylabel('Val')
end       
end

function dX = system_for_ode(t,X)
    
    % demo 2 system
    dX(1,1) = cos(t)*X(1) + sin(t)*X(2);
    dX(2,1) = -sin(t)*X(1) + cos(t)*X(2);
        
end
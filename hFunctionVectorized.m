function [h1,h2,h3,h4,h5,h6] = hFunctionVectorized(delta,omega, e,m,v,theta,...
    pg,qg)
%HFUNCTIONVECTORIZED computes h(x,a,u); i.e., algebraic equations in DAE.  
%  [h1,h2,h3,h4,h5,h6] = hFunction(delta,e,theta,V,...
%     pg,qg,xq_vec,xprime_vec) computes the algebraic equations of 
% function h based on equations (2a)--(3b)
%
% Description of outputs:
% 1. h1: size(G,1) right-hand side of equation (2a)
% 2. h2: size(G,1) right-hand side of equation (2b)
% 3. h3: size(G,1) right-hand side of equation (2c)
% 4. h4: size(G,1) right-hand side of equation (2d)
% 5. h5: size(L,1) right-hand side of equation (3a)
% 6. h6: size(L,1) right-hand side of equation (3b)
%
% Description of inputs:
% 1. delta: size(G,1) instantaneous internal angle of generator in radians
% 2. e: size(G,1) instantaneous electromotive force
% 3. theta: size(N,1) instantaneous terminal angle of nodes in radians
% 4. V: size(N,1) instantaneous terminal voltage magnitude of nodes in
% pu volts
% 5. pg: size(G,1) instantaneous real power generated by the generator
% 6. qg: size(G,1) instantaneous reactive power generated by the generator
% 7. xq_vec: size(G,1) vector of quadrature axis synchronous reactance (pu)
% 8. xprime_vec: size(G,1) vector of direct axis transient reactance (pu)
% 
% See also hFunction

% h1--h4 size(G,1)
% h5,h6 size(L,1)

% system constants [these do not change]
global OMEGAS Sbase N G L NodeSet GenSet LoadSet YMat GMat BMat Cg...
    YffVec YftVec  YtfVec YttVec

%  indices [these  do not change]
global deltaIdx omegaIdx eIdx mIdx  ...
    thetaIdx vIdx pgIdx qgIdx  fIdx prefIdx  SlackIdx

% machine [these do not change]
global  TauVec XdVec XqVec XprimeVec DVec MVec TchVec FreqRVec...
    

% dynamical simulations 
global TFinal TPert FSample NSamples NPertSamples Mass...
PertSet PPertValues QPertValues NoiseVarianceSet 


% constants:
Xprime=diag(XprimeVec); 
Xq=diag(XqVec);

% vector variables:
thetag=theta(GenSet);
Vg=v(GenSet);


% matrix variables
E=diag(e);
V_g=diag(Vg);
VMat=diag(v);
CosMat=diag( cos(theta));
SinMat=diag( sin(theta));

h1=-pg+ inv(Xprime)*E*V_g*sin(delta-thetag)+...
   (1/2)*inv(Xq)*inv(Xprime)*(Xprime-Xq)*V_g*V_g*sin(2*(delta-thetag));
  

h2=-qg+inv(Xprime)*E*V_g*cos(delta-thetag)-...
    (1/2)*inv(Xq)*inv(Xprime)*(Xprime+Xq)*V_g*Vg+ ...
    (1/2)*inv(Xq)*inv(Xprime)*(Xprime-Xq)*V_g*V_g*cos(2*(delta-thetag));



h35=VMat*CosMat*GMat*VMat*cos(theta)-VMat*CosMat*BMat*VMat*sin(theta)...
  +VMat*SinMat*BMat*VMat*cos(theta)+VMat*SinMat*GMat*VMat*sin(theta)-Cg*pg;

h3=h35(GenSet);
h5=h35(LoadSet);

h46=VMat*SinMat*GMat*VMat*cos(theta)-VMat*SinMat*BMat*VMat*sin(theta)...
  -VMat*CosMat*BMat*VMat*cos(theta)-  VMat*CosMat*GMat*VMat*sin(theta)-Cg*qg;
h4=h46(GenSet);
h6=h46(LoadSet);

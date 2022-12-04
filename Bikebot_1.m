% Subscripts: T total, R rear wheel, B rear frame, H front body (handlebar +
% fork), F rear wheel, A front assembly (H + F)

%*********************NOTE MKSR UNITS***********************

% basic geometric parameters
c = 0.0448; %orthogonal distance from steer axis to front wheel contact to ground, Q
w = 0.96468; %wheel span
lambda = pi/10; %camber angle (radians)

%mass of four rigid bodies
m_R = 3.405; %rear wheel mass
m_B = 17.71; %rear frame mass
m_H = 1.61; %front frame mass
m_F = 3.405; %front wheel mass

%COM_x distance of both frames
x_B = 0.4521963; %rear frame COM_x 
x_H = 0.865528645; %front frame COM_x

%radius of wheels
r_R = 0.254; %rear wheel radius
r_F = 0.254; %front wheel radius

%COM_z distance of both frames
z_B = -0.371334; %rear frame COM_z
z_H = -0.32045; %front frame COM_z

%MOIs and POIs
I_Rxx = 0.0603; 
I_Bxx = 1.01; 
I_Hxx = 0.01;  
I_Fxx = 0.0603; 
I_Bxz = 0;  
I_Hxz = 0; 
I_Ryy = 2*I_Rxx;
I_Fyy = 2*I_Fxx;
I_Rzz = I_Rxx;
I_Bzz = 0.57;  
I_Hzz = 0.01; 
I_Fzz = I_Fxx;


%Fundamental Parameters
m_T = m_R + m_B + m_H + m_F; %total mass of bike
x_T = (x_B*m_B + x_H*m_H + w*m_F) / m_T; %COM_x total
z_T = (-1*r_R*m_R + z_B*m_B + z_H*m_H - r_F*m_F) / m_T; %COM_z total
I_Txx = I_Rxx + I_Bxx + I_Hxx + I_Fxx + (m_R*r_R^2) + (m_B*z_B^2) + (m_H*z_H^2) + (m_F*r_F^2);%total mass MOI about x
I_Txz = I_Bxz + I_Hxz - m_B*x_B*z_B - m_H*x_H*z_H + m_F*w*r_F;%total mass POI about x
I_Tzz = I_Rzz + I_Bzz + I_Hzz + I_Fzz + (m_B*x_B^2) + (m_H*x_H^2) + (m_F*w^2);%total mass MOI about z
m_A = m_H + m_F; %mass of assembly
x_A = (x_H*m_H + w*m_F) / m_A; %assembly COM_x
z_A = (z_H*m_H - r_F*m_F) / m_A; %assembly COM_z
I_Axx = I_Hxx + I_Fxx + (m_H*(z_H - z_A)^2) + (m_F*(r_F + z_A)^2); %Mass MOI of assembly in x dir
I_Axz = I_Hxz - (m_H*(x_H - x_A)*(z_H - z_A)) + (m_F*(w-x_A)*(r_F + z_A)); %Mass POI of assembly
I_Azz = I_Hzz + I_Fzz + (m_H*(x_H - x_A)^2) + (m_F*(w - x_A)^2); %Mass MOI of assembly in z dir
u_A = (x_A - w - c)*cos(lambda) - z_A*sin(lambda); %orthogonal distance from COM of assembly to steer axis
I_All = (m_A*u_A^2) + (I_Axx*(sin(lambda)^2)) + 2*I_Axz*sin(lambda)*cos(lambda) + (I_Azz*(cos(lambda))^2); %Mass MOI of assembly in lambda dir
I_Alx = -1*m_A*u_A*z_A + I_Axx*sin(lambda) + I_Axz*cos(lambda); %Mass POI of assembly due to x motions
I_Alz = m_A*u_A*x_A + I_Axz*sin(lambda) + I_Azz*cos(lambda); %Mass POI of assembly due to z motions
mu = (c/w)*cos(lambda); %ratio of mechanical trail (ortho distance of steer axis to front contact Q) to wheel span
S_R = I_Ryy/r_R; %Gyrostatic coeff of rear wheel
S_F = I_Fyy/r_F; %Gyrostatic coeff of front wheel
S_T = S_R + S_F; %Gyrostatic coeff of total
S_A = m_A*u_A + mu*m_T*x_T; %Gyrostatic coeff of assembly


v = 4; %accel not velo

%Matrix Elements for ODE
%1 --> phi_phi
%2 --> phi_del
%3 --> del_phi
%4 --> del_del

M_1 = I_Txx;
M_2 = I_Alx+mu*I_Txz;
M_3 = I_Alx+mu*I_Txz;
M_4 = I_All+2*mu*I_Alz+(mu^2)*I_Tzz;
C_1 = 0;
C_2 = mu*S_T+S_F*cos(lambda)+(I_Txz/w)*cos(lambda)- mu*m_T*z_T;
C_3 = -1*(mu*S_T+S_F*cos(lambda));
C_4 = (I_Alz/w)*cos(lambda)+mu*(S_A+(I_Tzz/w)*cos(lambda));
K0_1 = m_T*z_T;
K0_2 = -1*S_A;
K0_3 = -1*S_A;
K0_4 = -1*S_A*sin(lambda);
K2_1 = 0;
K2_2 = ((S_T-m_T*z_T)/w)*cos(lambda);
K2_3 = 0;
K2_4 = ((S_A+S_F*sin(lambda))/w)*cos(lambda);

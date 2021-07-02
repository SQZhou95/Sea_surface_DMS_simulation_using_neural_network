% DMS total transfer coefficient calculation as Mart¨ª Gal¨ª (2020), PNAS
% Rewritten by SQ Zhou based on the R script contributed by Martin Johnson: 
% Johnson, M. T. "A numerical scheme to calculate temperature and salinity
% dependent air-water transfer velocities for any gas." Ocean Science 6.4
% (2010): 913-932. doi:10.5194/os-6-913-2010
% The original script is available from http://www.ocean-sci.net/6/913/2010/os-6-913-2010-supplement.zip
function Kt=Kt_DMS(T,U,S) % unit: m/s

    % KH = C_air/C_water, unit: dimensionless. M. T. Johnson (2010), Ocean Science.
    KH0=12.2./((273.15+T).*0.5.*exp(3100*(1./(273.15+T)-1/298.15)));
    Vb=75.82; % molar volume of DMS at boiling point, Korson (1969), JPC
    theta=7.33533e-4+3.39615e-5*log(KH0)-2.40888e-6*(log(KH0)).^2+1.57114e-7*(log(KH0)).^3;
    Ks=theta*log(Vb);
    KHf=10.^(Ks.*S);
    KH=KH0.*KHf;


    % Ka, unit: m/s. M. T. Johnson (2010), Ocean Science.
    Cd=1e-4*(6.1+0.63*U);
    u_star=U.*sqrt(Cd);
    % dynamic viscosity of saturated air according to Tsiligiris 2008
    SV_0 = 1.715747771e-5;
    SV_1 = 4.722402075e-8;
    SV_2 = -3.663027156e-10;
    SV_3 = 1.873236686e-12;
    SV_4 = -8.050218737e-14;
    u_m = SV_0+(SV_1*T)+(SV_2*T.^2)+(SV_3*T.^3)+(SV_4*T.^4);
    % density of saturated air according to Tsiligiris 2008 in kg/m^3
    SD_0 = 1.293393662;
    SD_1 = -5.538444326e-3;
    SD_2 = 3.860201577e-5;
    SD_3 = -5.2536065e-7;
    p = SD_0+(SD_1*T)+(SD_2*T.^2)+(SD_3*T.^3);
    % calculate diffusivity in air in cm2/sec
    M_r=sqrt((62.13+28.97)/(62.13*28.97));
    V_a=20.1;
    D_air=(0.001*((T+273.15).^1.75)*sqrt(M_r))/(1*(V_a^(1/3)+Vb^(1/3))^2);
    % calculate the schmidt number of DMS in air
    Sc_a=1e4*u_m./p./D_air;
    % use new Ka formulation, based on Jeffrey et al. (2010), Ocean Modelling
    von_kar=0.4;
    Ka = 1e-3 + u_star./(13.3*sqrt(Sc_a) + Cd.^(-0.5) - 5 + log(Sc_a)/(2*von_kar));


    % Kw of DMS based on Woolf (1997) (bubble mechanism), unit: m/s
    Sc_w = 2674.0 - 147.12*T + 3.726*T.^2 - 0.038*T.^3; % Saltzman (1992), JGR
    W_b=3.84e-6 * (U.^(3.41));
    beta=1./KH;
    denominator=beta.*(1+((14*beta.*(Sc_w.^(-0.5))).^(-1/1.2))).^1.2;
    K_b = 2540*W_b./denominator;
    % K_o is non-whitecapping friction velocity relationship component of k_w
    K_o=1.57e-4*u_star.*((600./Sc_w).^0.5);
    Kw=((K_o*360000) + K_b)/360000;
    % Kw_Ni=(0.222*U.^2+0.333*U)./sqrt(Sc_w/600)/360000; % Nightingale (2000),
    % GBC. It was applied in DMS flux calculation of Lana (2011), GBC


    Kt=1./(1./(KH.*Ka)+1./Kw);

end
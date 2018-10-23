clc;
clear all;
%CONSTRUCAO DA GRELHA
[nodos,elementos]=geracao_grelha();
%METODO FEM
U = 10; %potencial na fronteira x=-0.5
numeroNodos = length(nodos);
numeroElementos = length(elementos);
nodosTotal=1:length(nodos);
A = zeros(numeroNodos);
b = zeros(numeroNodos,1);
for elIdx = 1:numeroElementos
    % Buscar os nodos e suas coordenadas e calcular a sua contribuicao para
    % A
    no = elementos(elIdx,:);
    xy = nodos(no,:);
    A_el = CmpElMtx(xy);
    A(no,no) = A(no,no) + A_el;
end
fd=inline('drectangle(p,-0.5,0.5,-0.5,0.5)','p');
distanciaFronteiraNodos=fd(nodos);
nodosFronteira=[];
for i=1:numeroNodos
    if (distanciaFronteiraNodos(i)<=1e-4 & ((nodos(i,1)<=-0.48 & nodos(i,2)>=0))|(nodos(i,1)>=0 & nodos(i,2)<=-0.49));
        nodosFronteira=[nodosFronteira i];
    end
end
% Sacar os indices dos nodos interiores
nodosInteriores=setdiff(nodosTotal,nodosFronteira);
% Selecionar as partes da matriz necessarias para resolver o problema
A_fronteira= A(nodosFronteira,nodosInteriores);
A_interior= A(nodosInteriores,nodosInteriores);
b=zeros(length(nodosInteriores),1);
z= zeros(length(nodosTotal),1);
%selecionar os nodos da fronteira em U != 0
nodosFronteiray0=[];
nodosFronteirax0=[];
for i=1:length(nodosFronteira);
    if (nodos(nodosFronteira(i),1)<=-0.48 & nodos(nodosFronteira(i),2)>=0)
        nodosFronteiray0=[nodosFronteiray0 i];
    end
end
z(nodosFronteiray0)=U;
zFronteira=z(nodosFronteira);
nodosFronteirax0=nodosFronteira(~ismember(nodosFronteira,nodosFronteiray0));
% Resolver o sistema de eqs linear
z_nat = A_interior\(b - transpose(A_fronteira)*zFronteira);
% juntar todas as partes da solucao
z = zeros(length(nodosTotal),1);
z(nodosFronteira) = zFronteira;
z(nodosInteriores) = z_nat;

%graficos
%grafico do potencial eletrico
figure(2);
trisurf(elementos,nodos(:,1),nodos(:,2),z);
xlabel('x(m)');
ylabel('y(m)');
zlabel('Potencial elétrico (V)');
title('Representação 3D do potencial na grelha');
%representacao da base em x=-0.5
figure(3);
zx0=zeros(length(nodosTotal),1);
zx0(nodosFronteirax0(1)) = 1;
trisurf(elementos,nodos(:,1),nodos(:,2),zx0);
xlabel('x(m)');
ylabel('y(m)');
title('Função da base em L1');
%representacao da base em y=-0.5
figure(4);
zlinhalinha=zeros(length(nodosTotal),1);
zlinhalinha(nodosFronteiray0(1)) = 1;
trisurf(elementos,nodos(:,1),nodos(:,2),zlinhalinha);
xlabel('x(m)');
ylabel('y(m)');
title('Função da base em L3');
% Calculo da resistência
R = 100/(transpose(z)*A*z);
disp(['Resistance [ohm] = ', num2str(R)]);

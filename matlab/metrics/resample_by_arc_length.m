function trayectoria_resampleada = resample_by_arc_length(trayectoria_original, num_puntos_deseados)
% Resamplea una trayectoria 2D basada en la longitud de arco.
%
% Args:
%   trayectoria_original: Matriz N x 2 donde cada fila es un punto [x, y].
%   num_puntos_deseados: Número de puntos que tendrá la trayectoria resampleada.
%
% Returns:
%   trayectoria_resampleada: Matriz num_puntos_deseados x 2 con la trayectoria resampleada.

    % 1. Calcular la longitud de arco acumulada
    distancias_segmentos = sqrt(sum(diff(trayectoria_original).^2, 2));
    longitud_arco_acumulada = [0; cumsum(distancias_segmentos)];
    longitud_total = longitud_arco_acumulada(end);

    % 2. Definir las longitudes de arco deseadas para los nuevos puntos
    longitudes_deseadas = linspace(0, longitud_total, num_puntos_deseados)';

    % 3. Encontrar los puntos correspondientes a las longitudes de arco deseadas
    trayectoria_resampleada = interp1(longitud_arco_acumulada, trayectoria_original, longitudes_deseadas, 'linear');

    % Si el último punto no coincide exactamente debido a la interpolación,
    % lo forzamos a ser el último punto original (opcional)
    trayectoria_resampleada(end,:) = trayectoria_original(end,:);
end

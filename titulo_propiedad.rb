#encoding: utf-8
require_relative "jugador"
module ModeloQytetet
  class TituloPropiedad
    attr_reader :nombre, :precioCompra, :alquilerBase, :factorRevalorizacion, :hipotecaBase, :precioEdificar, :numHoteles, :numCasas, :propietario
    attr_accessor :hipotecada, :propietario
      def initialize(nombre, precioCompra, precioEdificar, factorRevalorizacion, alquilerBase, hipotecaBase)
        @hipotecada = false
        @numHoteles = 0
        @numCasas = 0
        @nombre = nombre
        @propietario = nil
        
        if precioCompra >= 500 && precioCompra <= 1000
          @precioCompra = precioCompra
        else
          @precioCompra = 500
        end
        
        if precioEdificar >= 250 && precioEdificar <= 750
          @precioEdificar = precioEdificar
        else
          @precioEdificar = 250
        end
        
        if factorRevalorizacion >= 10 && factorRevalorizacion <= 20
          @factorRevalorizacion = precioEdificar
        elsif factorRevalorizacion >= -20 && factorRevalorizacion <= -10
          @factorRevalorizacion = precioEdificar
        else
          @factorRevalorizacion = 10
        end
        
        if alquilerBase >= 50 && alquilerBase <= 100
          @alquilerBase = alquilerBase
        else

          @alquilerBase = 50
        end
        
        if hipotecaBase >= 150 && hipotecaBase <= 1000
          @hipotecaBase = hipotecaBase
        else
          @alquilerBase = 150
        end
      end
      
      def calcularCosteCancelar
        costeCancelar = calcularCosteHipotecar
        costeCancelar = costeCancelar + (costeCancelar * 0.1)
        costeCancelar.to_i
      end
      
      def calcularCosteHipotecar
        return (@hipotecaBase + @numCasas * 0.5 * @hipotecaBase + @numHoteles * @hipotecaBase).to_i
      end
      
      def calcularImporteAlquiler
        costeAlquiler = @alquilerBase + (@numCasas * 0.5 + @numHoteles * 2).to_i
        
        costeAlquiler
      end
      
      def calcularPrecioVenta
        return (@precioCompra + ( @numCasas + @numHoteles ) * @precioEdificar * @factorRevalorizacion).to_i
      end
      
      def cancelarHipoteca
        @hipotecada = false
        return true
      end
      
      def edificarCasa()
        @numCasas = @numCasas + 1
      end
      
      def edificarHotel()
        @numHoteles = @numHoteles + 1
        @numCasas = 0
      end
      
      def hipotecar()
        @hipotecada = true
        costeHipoteca = calcularCosteHipotecar
        costeHipoteca
      end
      
      def pagarAlquiler()
        costeAlquiler = self.calcularImporteAlquiler
        @propietario.modificarSaldo(costeAlquiler)
        costeAlquiler
      end
      
      def propietarioEncarcelado()
        @propietario.encarcelado
      end
      
      def tengoPropietario()
        if(@propietario == nil)
          return false
        else
          return true
        end
      end
      
      def to_s
        texto = "\nNombre propiedad: #{@nombre}\nHipotecada: "
        
        if@hipotecada == true
          texto << "Sí"
        else
          texto << "No"
        end
        texto << "\nPrecio de compra: #{@precioCompra}\nAlquiler base: #{@alquilerBase}\nFactor de revalorizacion: #{@factorRevalorizacion}\nHipoteca base: #{@hipotecaBase}\nPrecio de edificar: #{@precioEdificar}\nNumero de hoteles/casas: #{@numHoteles}/#{@numCasas}"
        texto
      end
      
  end
end

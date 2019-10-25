#encoding: utf-8
require_relative "casilla"
module ModeloQytetet
  class Jugador
    attr_reader :nombre, :propiedades, :saldo, :cartaLibertad
    attr_accessor :casillaActual, :encarcelado
    
    def initialize(nombre)
      @encarcelado = false;
      @nombre = nombre;
      @saldo = 7500;
      @cartaLibertad = nil;
      @casillaActual = nil;
      @propiedades = Array.new
    end
    
    def self.nuevo(nombre)
      new(nombre)
    end
    
    def self.copiar(otroJugador)
      @nombre = otroJugador.nombre
      @saldo = otroJugador.saldo
      @propiedades = otroJugador.propiedades
      @cartaLibertad = otroJugador.cartaLibertad
      @casillaActual = otroJugador.casillaActual
      @encarcelado = otroJugador.encarcelado
    end
    
    private_class_method :new
     
    def <=>(otroJugador)
      otroCapital= otroJugador.obtenerCapital
      miCapital = obtenerCapital
      if otroCapital > miCapital
        return 1 
      end
      if otroCapital < miCapital
        return -1
      end
      return 0
    end
    
    def setCartaLibertad(cartaLibertad)
      if cartaLibertad.tipo == TipoSorpresa::SALIRCARCEL
        @cartaLibertad = cartaLibertad
      end
    end
  
    def cancelarHipoteca(titulo)
      cancelar = false
      costeCancelar = titulo.calcularCosteCancelar
      tengoSaldo = tengoSaldo(costeCancelar)
      
      if tengoSaldo
        modificarSaldo(-costeCancelar)
        cancelar = titulo.cancelarHipoteca
      end
      
      cancelar
    end
  
    def comprarTituloPropiedad
      comprado = false
      costeCompra = @casillaActual.coste
      
      if costeCompra < @saldo
        comprado = true
        @casillaActual.titulo.propietario = self
        @propiedades << @casillaActual.titulo
        self.modificarSaldo(-costeCompra)
      end
      
      comprado
    end
  
    def deboPagarAlquiler
      titulo = @casillaActual.titulo
      esDeMiPropiedad = esDeMiPropiedad(titulo)
      tienePropietario = false
      encarcelado = true
      estaHipotecada = true

      if (esDeMiPropiedad == false)
        tienePropietario = titulo.tengoPropietario
        if tienePropietario
          encarcelado = titulo.propietarioEncarcelado
          if !encarcelado
            estaHipotecada = titulo.hipotecada
          end
        end
      end
      debopagar = !esDeMiPropiedad && tienePropietario && !encarcelado && !estaHipotecada
      debopagar
    end


    def cuantasCasasHotelesTengo()
      numpropiedades = 0
      
      for i in 0...@propiedades.size
        numpropiedades = numpropiedades + @propiedades[i].numCasas + @propiedades[i].numHoteles
      end
      return numpropiedades
    end
  
    def devolverCartaLibertad()
      carta = @cartaLibertad
      @cartaLibertad = nil
      return carta

    end
  
    def edificarCasa(titulo)
      edificada = false
      
      numCasas = titulo.numCasas
      
      if puedoEdificarCasa(titulo)
        costeEdificarCasa = titulo.precioEdificar
        tengoSaldo = self.tengoSaldo(costeEdificarCasa)
        
        if(tengoSaldo)
          titulo.edificarCasa
          self.modificarSaldo(-costeEdificarCasa)
          edificada = true
        end
      end
      
      edificada
    end
  
    def puedoEdificarCasa(titulo)
      numCasas = titulo.numCasas
      return numCasas < 4
    end
    
    def puedoEdificarHotel(titulo)
      numHoteles = titulo.numHoteles
      numCasas = titulo.numCasas
      return (numHoteles < 4 and numCasas == 4)
    end
    
    def edificarHotel(titulo)
      edificado = false
      
      numHoteles = titulo.numHoteles
      numCasas = titulo.numCasas
      
      if puedoEdificarHotel(titulo)
        costeEdificarHotel = titulo.precioEdificar
        tengoSaldo = self.tengoSaldo(costeEdificarHotel)
        
        if(tengoSaldo)
          titulo.edificarHotel
          self.modificarSaldo(-costeEdificarHotel)
          edificado = true
        end
      end
      
      edificado
    end
  
    def eliminarDeMisPropiedades(titulo)
      @propiedades.delete(titulo)
      titulo.propietario = nil
    end
  
    def esDeMiPropiedad(titulo)
      deMiPropiedad = false
      for i in 0...@propiedades.size
        if (titulo == @propiedades[i])
          deMiPropiedad = true
        end
      end
      return deMiPropiedad
    end
  
    def estoyEnCalleLibre()
      raise NotImplementedError
    end
  
    def hipotecarPropiedad(titulo)
      costeHipoteca = titulo.hipotecar
      modificarSaldo(costeHipoteca)
    end
  
    def irACarcel(casilla)
      @casillaActual = casilla
      @encarcelado = true
    end
  
    def modificarSaldo(cantidad)
      @saldo += cantidad
      return @saldo
    end
  
    def obtenerCapital()
      capital = @saldo
      for i in 0...@propiedades.size
        capital = capital + @propiedades[i].precioCompra + (@propiedades[i].numCasas + @propiedades[i].numHoteles) + @propiedades[i].precioEdificar
        if (@propiedades[i].hipotecada == true)
          capital = capital - @propiedades[i].hipotecaBase
        end
      end
      
      capital
    end
  
    def obtenerPropiedades(hipotecada) 
      tp = array.new
      for i in 0...@propiedades.size
        if (@propiedades[i].hipotecada == hipotecada)
          tp << @propiedades[i]
        end
      end
      return tp
    
    end
  
    def pagarAlquiler
      costeAlquiler = @casillaActual.pagarAlquiler
      self.modificarSaldo(-costeAlquiler)
    end

    def pagarImpuesto()
      @saldo = @saldo - @casillaActual.coste
    end
  
    def pagarLibertad(cantidad)
      tengoSaldo = self.tengoSaldo(cantidad)
      
      if tengoSaldo
        @encarcelado = false
        self.modificarSaldo(-cantidad)
      end
    end
  
    def tengoCartaLibertad()
      return @cartaLibertad
    end
  
    def tengoSaldo(cantidad)
      if (@saldo >= cantidad)
        return true
      else
        return false
      end
    end
  
    def venderPropiedad(casilla)
      titulo = casilla.titulo
      eliminarDeMisPropiedades(titulo)
      precioVenta = titulo.calcularPrecioVenta
      modificarSaldo(precioVenta)
    end
  
    def convertirme (fianza)
      especulador = Especulador.copia(self, fianza)
      return especulador
    end
    
    def deboIrACarcel
      !tengoCartaLibertad
    end
    
    def to_s
      texto = "\nNombre: #{@nombre}\nSaldo: #{@saldo}\nCapital: #{obtenerCapital()}\nEncarcelado: #{@encarcelado}\nEsta en la casilla: #{@casillaActual}\nCarta libertad: #{@cartaLibertad}\nPropiedades: \n"
      
      for i in 0...@propiedades.size
        texto += "#{@propiedades[i]}\n"
      end
      return texto
    end
  end
end


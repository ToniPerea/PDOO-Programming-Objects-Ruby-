#encoding: utf-8
require_relative "Sorpresa"
require_relative "tablero"
require_relative "jugador"
require_relative "dado"
require_relative "estado_juego"
require_relative "metodo_salir_carcel"
require_relative "TipoSorpresa"
require "singleton"

module ModeloQytetet
  class Qytetet
    include Singleton
    attr_reader :mazo, :cartaActual, :jugadorActual, :jugadores, :tablero, :metodosalircarcel, :dado, :estado
    
    def initialize
        @@MAX_JUGADORES = 4
        @@NUM_SORPRESAS = 10
        @@NUM_CASILLAS = 20
        @@PRECIO_LIBERTAD = 200
        @@SALDO_SALIDA = 1000
        @dado = Dado.instance
        @estado = nil
        @cartaActual = nil
        @metodosalircarcel = nil
        @jugadores = nil
    end
    
    def self.getMaxJugadores
      @@MAX_JUGADORES
    end
    
    def actuarSiEnCasillaEdificable
      deboPagar = @jugadorActual.deboPagarAlquiler
      
      if deboPagar
        @jugadorActual.pagarAlquiler
        
        if @jugadorActual.saldo <= 0
          @estado = EstadoJuego::ALGUNJUGADORENBANCAROTA
        end
      end

      casilla = @jugadorActual.casillaActual
      
      tengoPropietario = casilla.tengoPropietario
      
      if @estado != EstadoJuego::ALGUNJUGADORENBANCARROTA
        if tengoPropietario
          @estado = EstadoJuego::JA_PUEDEGESTIONAR
        else
          @estado = EstadoJuego::JA_PUEDECOMPRAROGESTIONAR
        end
      end
    end
    
    def actuarSiEnCasillaNoEdificable
      @estado = EstadoJuego::JA_PUEDEGESTIONAR
      
      casillaActual = @jugadorActual.casillaActual
      
      if casillaActual.tipo == TipoCasilla::IMPUESTO
        @jugadorActual.pagarImpuesto
      
      elsif casillaActual.tipo == TipoCasilla::JUEZ
        encarcelarJugador
        
      elsif casillaActual.tipo == TipoCasilla::SORPRESA
        @cartaActual = @mazo[0]
        @mazo.delete_at(0)
        @mazo << @cartaActual
        @estado = EstadoJuego::JA_CONSORPRESA
      end
    end
    
    def aplicarSorpresa
      @estado = EstadoJuego::JA_PUEDEGESTIONAR
      
      if @cartaActual.tipo == TipoSorpresa::SALIRCARCEL
        @jugadorActual.setCartaLibertad(@cartaActual)
        
      else
        @mazo << @cartaActual
        
        if @cartaActual.tipo == TipoSorpresa::PAGARCOBRAR
        @jugadorActual.modificarSaldo(@cartaActual.valor)
          if @jugadorActual.saldo < 0
            @estado = EstadoJuego::ALGUNJUGADORENBANCAROTA
          end
        
        elsif @cartaActual.tipo == TipoSorpresa::IRACASILLA
          valor = @cartaActual.valor
          casillaCarcel = @tablero.esCasillaCarcel(valor)
          if casillaCarcel
            encarcelarJugador
            mover(valor)
          else
            self.mover(valor)
          end

        elsif @cartaActual.tipo == TipoSorpresa::PORCASAHOTEL
          cantidad = @cartaActual.valor
          numeroTotal = @jugadorActual.cuantasCasasHotelesTengo
          @jugadorActual.modificarSaldo(cantidad*numeroTotal)

          if @jugadorActual.saldo < 0
            @estado = EstadoJuego::ALGUNJUGADORENBANCAROTA
          end

        elsif @cartaActual.tipo == TipoSorpresa::PORJUGADOR
          for i in 0...@jugadores.size
            jugador = @jugadores[i]

            if jugador != @jugadorActual
              jugador.modificarSaldo(@cartaActual.valor)
              if jugador.saldo < 0
                @estado = EstadoJuego::ALGUNJUGADORENBANCAROTA
              end

              @jugadorActual.modificarSaldo(-@cartaActual.valor)

              if @jugadorActual.saldo < 0
                @estado = EstadoJuego::ALGUNJUGADORENBANCAROTA
              end
            end
          end
        elsif @cartaActual.tipo == TipoSorpresa::CONVERTIRME
          
          @jugadores[@iterador] = @jugadorActual.convertirme(@cartaActual.valor)       
        end
      end
    end
    
    def cancelarHipoteca(numeroCasilla)
      casilla = @tablero.obtenerCasillaNumero(numeroCasilla)
      esEdificable = casilla.soyEdificable
      titulo = casilla.titulo
      esDeMiPropiedad = @jugadorActual.esDeMiPropiedad(titulo)
      hipotecada = titulo.hipotecada
      cancelar = false

      if esEdificable && esDeMiPropiedad && hipotecada
        cancelar = @jugadorActual.cancelarHipoteca(titulo)
      end
      
      @estado = EstadoJuego::JA_PUEDEGESTIONAR
      
      cancelar
    end
    
    def comprarTituloPropiedad
      comprado = @jugadorActual.comprarTituloPropiedad
      if comprado
        @estado = EstadoJuego::JA_PUEDEGESTIONAR
      end
      
      comprado
    end
    
    def edificarCasa(numeroCasilla)
      casilla = @tablero.obtenerCasillaNumero(numeroCasilla)
      titulo = casilla.titulo
      edificada = @jugadorActual.edificarCasa(titulo)
      
      if edificada
        @estado = EstadoJuego::JA_PUEDEGESTIONAR
      end
      
      edificada
    end
    
    def edificarHotel(numeroCasilla)
      casilla = @tablero.obtenerCasillaNumero(numeroCasilla)
      titulo = casilla.titulo
      edificado = @jugadorActual.edificarHotel(titulo)
      
      if edificado
        @estado = EstadoJuego::JA_PUEDEGESTIONAR
      end
      
      edificado
    end
    
    def encarcelarJugador
      unless @jugadorActual.deboIrACarcel
        casillaCarcel = @tablero.carcel
        @jugadorActual.irACarcel(casillaCarcel)
        @estado = EstadoJuego::JA_ENCARCELADO
      else
        carta = @jugadorActual.devolverCartaLibertad
        @mazo << carta
        @estado = EstadoJuego::JA_PUEDEGESTIONAR
      end  
    end
    
    def getValorDado
       @dado.valor
    end
    
    def hipotecarPropiedad(numeroCasilla)
      casilla = @tablero.obtenerCasillaNumero(numeroCasilla)
      titulo = casilla.titulo
      @jugadorActual.hipotecarPropiedad(titulo)
      @estado = EstadoJuego::JA_PUEDEGESTIONAR
    end
    
    def inicializarCartasSorpresa
      @mazo = Array.new

      @mazo << Sorpresa.new("Es tu cumpleaños!! Todos los juegadores te dan 200 euros", 200, TipoSorpresa::PORJUGADOR)
      @mazo << Sorpresa.new("Has ganado la loteria del barrio. Cobras 400 euros", 400, TipoSorpresa::PAGARCOBRAR)
      @mazo << Sorpresa.new("Te han descubierto una pistola en tu coche.Vas a la carcel",@tablero.carcel.numeroCasilla, TipoSorpresa::IRACASILLA)
      @mazo << Sorpresa.new("Te hemos pillado transportando nesquik y Cola-Cao a la misma vez.", @tablero.carcel.numeroCasilla, TipoSorpresa::IRACASILLA)
      @mazo << Sorpresa.new("El 7 dicen que da suerte. Vamos a comprobarlo mandandote a esa casilla.", 7, TipoSorpresa::IRACASILLA)
      @mazo << Sorpresa.new("No fue buena idea invitar a comer a tus primos. Paga 200 euros",-200, TipoSorpresa::PAGARCOBRAR)
      @mazo << Sorpresa.new("Menuda tormenta, hay que hacer reparaciones; paga 100 euros por casa u hotel", 100, TipoSorpresa::PORCASAHOTEL)
      @mazo << Sorpresa.new("Paga la fianza de tu padre, 300 euros.", -300, TipoSorpresa::PAGARCOBRAR)
      @mazo << Sorpresa.new("Un fan anónimo ha pagado tu fianza. Sales de la cárcel", 0, TipoSorpresa::SALIRCARCEL)
      @mazo << Sorpresa.new("Hay un incendio ¡Ve al Callejón Tenebroso!", 1, TipoSorpresa::IRACASILLA)
      @mazo << Sorpresa.new("Te conviertes en especulador de fianza 3000",3000, TipoSorpresa::CONVERTIRME)
      @mazo << Sorpresa.new("Te conviertes en especulador de fianza 5000", 5000, TipoSorpresa::CONVERTIRME)

      
      @mazo = @mazo.shuffle
    end
    
    def inicializarJuego(nombres)
      inicializarJugadores(nombres)
      inicializarTablero
      inicializarCartasSorpresa
      salidaJugadores
    end
    
    def inicializarJugadores(nombres)
      @jugadores = Array.new
      for i in 0...nombres.size
        @jugadores << Jugador.nuevo(nombres[i])
      end
    end
    
    def inicializarTablero
      @tablero = Tablero.new
    end
    
    def intentarSalirCarcel(metodo)
      if metodo == MetodoSalirCarcel::TIRANDODADO
        resultado = tirarDado
        if resultado >= 5
          @jugadorActual.encarcelado = false
        end
        
      elsif metodo == MetodoSalirCarcel::PAGANDOLIBERTAD
        @jugadorActual.pagarLibertad(@@PRECIO_LIBERTAD)
      end
      
      libre = @jugadorActual.encarcelado
      
      if libre
        @estado = EstadoJuego::JA_ENCARCELADO
      else
        @estado = EstadoJuego::JA_PREPARADO
      end
      
      libre
    end
    
    def jugar
      resultadoDado = tirarDado
      casillaFinal = @tablero.obtenerCasillaFinal(obtenerCasillaJugadorActual, resultadoDado)
      mover(casillaFinal.numeroCasilla)
    end
    
    def mover(numCasillaDestino)
      casillaInicial = obtenerCasillaJugadorActual
      casillaFinal = @tablero.obtenerCasillaNumero(numCasillaDestino)
      @jugadorActual.casillaActual = casillaFinal
      
      if numCasillaDestino < casillaInicial.numeroCasilla
        @jugadorActual.modificarSaldo(@@SALDO_SALIDA)        
      end
      
      if casillaFinal.soyEdificable
        self.actuarSiEnCasillaEdificable
      
      else
        self.actuarSiEnCasillaNoEdificable
      end
    end
    
    def obtenerCasillaJugadorActual
      @jugadorActual.casillaActual
    end
    
    def obtenerPropiedadesJugador
      propiedadesJA = Array.new
      casillas = Array.new
      ncasillas = Array.new
      propiedadesJA = @jugadorActual.propiedades
      casillas = @tablero.casillas
      for propiedad in propiedadesJA do
        for casilla in casillas do
          if (casilla.titulo == propiedad.titulo)
            ncasillas << casilla.numeroCasilla
          end
        end
      end
      return ncasillas
    end
    
    def obtenerPropiedadesJugadorSegunEstadoHipoteca(estadoHipoteca)
      propiedadesJA = Array.new
      casillas = Array.new
      casillasHip = Array.new
      propiedadesJA = @jugadorActual.propiedades
      casillas = @tablero.casillas
      for propiedad in propiedadesJA do
        for casilla in casillas do
          if (casilla.titulo == propiedad.titulo and propiedad.titulo.hipotecada == estadoHipoteca)
            casillasHip << casilla.numeroCasilla
          end
        end
      end
      return casillasHip
    end
    
    def obtenerRanking
      @jugadores=@jugadores.sort
    end
    
    def ObtenerSaldoJugadorActual
      @jugadorActual.saldo
    end 
    
    def salidaJugadores
      for jugador in @jugadores do
        jugador.casillaActual = @tablero.obtenerCasillaNumero(0)
      end
      #turno = Random.new
      primero = rand(0...@jugadores.length)
      @jugadorActual = @jugadores[primero]
      @estado = EstadoJuego::JA_PREPARADO
    end
    
    def siguienteJugador
      index = @jugadores.index(@jugadorActual)
      index = (index + 1)%@jugadores.size
      @jugadorActual = @jugadores.at(index)
      if (@jugadorActual.encarcelado)
        @estado = EstadoJuego::JA_ENCARCELADOCONOPCIONDELIBERTAD
      else
        @estado = EstadoJuego::JA_PREPARADO
      end
    end
    
    def tirarDado
      @dado.tirar
    end
    
    def venderPropiedad(numeroCasilla)
      casilla = @tablero.obtenerCasillaNumero(numeroCasilla)
      @jugadorActual.venderPropiedad(casilla)
      @estado = EstadoJuego::JA_PUEDEGESTIONAR
    end
    
    private :encarcelarJugador, :inicializarCartasSorpresa, :inicializarJugadores, :inicializarTablero, :salidaJugadores
  end
end

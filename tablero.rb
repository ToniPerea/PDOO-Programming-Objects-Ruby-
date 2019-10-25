#encoding: utf-8
require_relative "TipoCasilla"
require_relative "casilla"
require_relative "calle"
require_relative "titulo_propiedad"
module ModeloQytetet
  class Tablero
    attr_reader :casillas, :carcel
    def initialize
      inicializar
    end
    
    private
    def inicializar
      @casillas = Array.new
      @casillas << Casilla.newSalida(0)
      titulo = TituloPropiedad.new("Callejon Tenebroso", 500,  620, 25, 73, 200)
      @casillas << Calle.newCalle(1, titulo)
      titulo = TituloPropiedad.new("Calle del Alcaide", 500, 620, 25, 73, 450)
      @casillas << Calle.newCalle(2, titulo)
      @casillas << Casilla.newSorpresa(3)
      titulo = TituloPropiedad.new("Plaza Mística", 800, 620, 25, 73,0)
      @casillas << Calle.newCalle(4, titulo)
      @casillas << Casilla.newCarcel(5)
      titulo = TituloPropiedad.new("Calle Sol", 700, 620, 25, 73, 600)
      @casillas << Calle.newCalle(6, titulo)
      @casillas << Casilla.newSorpresa(7)
      titulo = TituloPropiedad.new("Calle Finca Menor", 1000, 620, 25, 73, 900)
      @casillas << Calle.newCalle(8, titulo)
      titulo = TituloPropiedad.new("Calle Extravagancia", 1500, 620, 25, 73, 1300)
      @casillas << Calle.newCalle(9, titulo)
      @casillas << Casilla.newParking(10)
      titulo = TituloPropiedad.new("Calle Mercaderes", 1800, 620, 25, 73, 1600)
      @casillas << Calle.newCalle(11, titulo)
      titulo = TituloPropiedad.new("Calle Inocencia", 2200, 1000, 25, 73, 2000)
      @casillas << Calle.newCalle(12, titulo)
      @casillas << Casilla.newSorpresa(13)
      titulo = TituloPropiedad.new("Calle Certeza", 2600, 1200, 25, 73, 2500)
      @casillas << Calle.newCalle(14, titulo)
      @casillas << Casilla.newJuez(15)
      titulo = TituloPropiedad.new("Calle Justicia", 3000, 1500, 25, 73, 3000)
      @casillas << Calle.newCalle(16, titulo)
      titulo = TituloPropiedad.new("Calle Finca Mayor", 4000, 2000, 25, 73, 4000)
      @casillas << Calle.newCalle(17, titulo)
      @casillas << Casilla.newImpuesto(18, 100)
      titulo = TituloPropiedad.new("Villa Maravilla", 5000, 2400, 25, 73, 4500)
      @casillas << Calle.newCalle(19, titulo)
      
      @carcel = @casillas[5]
    end
    
    public
    
    def esCasillaCarcel(numeroCasilla)
      if (numeroCasilla ==  @carcel.numeroCasilla)
        return true
      else
        return false
      end
    end
    
    def obtenerCasillaFinal(casilla, desplazamiento)
      pos = casilla.numeroCasilla
      pos += desplazamiento
      pos = pos%(@casillas.size())
      return @casillas.at(pos)
    end
    
    def obtenerCasillaNumero(numeroCasilla)
      if(numeroCasilla < 0 || numeroCasilla > @casillas.size())
        return nil
      else
        return @casillas[numeroCasilla]
      end
    end
    
    
    public
    def to_s
      texto = ""
      
      for i in 0...@casillas.size
        texto += @casillas[i].to_s + "\n-----------------------------------------------\n"
      end
      
      texto
    end
  end
end

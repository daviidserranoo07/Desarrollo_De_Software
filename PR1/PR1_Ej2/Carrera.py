from abc import ABC, abstractmethod
class Carrera(ABC):
    def __init__(self):
        self.participantes= []
        self.tipo = "normal"

    @abstractmethod
    def mostrarTipo(self):
        pass

    def aniadirBici(self,bici):
        self.lista.append(bici)

    def getParticipantes(self):
        return self.participantes

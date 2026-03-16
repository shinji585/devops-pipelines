import time

def funcion_que_espera() -> bool: 
    print("Funcion que espera inicializada....")
    
    time.sleep(3)
    
    print("Funcion de espera terminada...")
    
    return True


# creamos el test 
def test_espera_funcion(): 
    assert funcion_que_espera() == True
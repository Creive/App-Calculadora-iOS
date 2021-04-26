//
//  ViewController.swift
//  iOS Calculadora 2
//
//  Created by Nicolas Russi on 5/04/21.
//

import UIKit

class ViewController: UIViewController {
    
    //MARK: - Outlets
    //Resultado Label
    @IBOutlet weak var resultLabel: UILabel!
    
    //Numbers
    @IBOutlet weak var number0: UIButton!
    @IBOutlet weak var number1: UIButton!
    @IBOutlet weak var number2: UIButton!
    @IBOutlet weak var number3: UIButton!
    @IBOutlet weak var number4: UIButton!
    @IBOutlet weak var number5: UIButton!
    @IBOutlet weak var number6: UIButton!
    @IBOutlet weak var number7: UIButton!
    @IBOutlet weak var number8: UIButton!
    @IBOutlet weak var number9: UIButton!
    @IBOutlet weak var numberDecimal: UIButton!
    
    //Operadores
    @IBOutlet weak var operatorAC: UIButton!
    @IBOutlet weak var operatorPlusMinus: UIButton!
    @IBOutlet weak var operatorPorcent: UIButton!
    @IBOutlet weak var operatorResult: UIButton!
    @IBOutlet weak var operatorAddition: UIButton!
    @IBOutlet weak var operatorSubstraction: UIButton!
    @IBOutlet weak var operatorMultiplication: UIButton!
    @IBOutlet weak var operatorDivision: UIButton!
    
    //MARK: - Variables
    private var total: Double = 0 //almacenar el resultado de la calculadora
    private var temp: Double = 0 //valor por pantalla (temporal)
    private var operating = false // tratar con operadores suma resta etc
    private var decimal = false // tratar con numeros decimales
    private var operation: OperationType = .none //operacion inicial ninguna
    
    //MARK: - constantes
    private let kDecimalSeparator = Locale.current.decimalSeparator //localidad
    private let kMaxLength = 9 //maximo numero de 9 cifras
    private let kTotal = "total" //guardar el resultado y mostrarlo cuando retomemos a la aplicacion
    
    
    /*private let kMaxValue: Double = 999999999 //valor maximo
    private let kMinValue: Double = 0.00000001 // valor minimo 8 digitos decimales
    */
    
    
    private enum OperationType {
        case none, addiction, substraction, multiplication, division, porcent
    }
    
    // Formateo De Valores Auxiliares
    private let auxFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        let locale = Locale.current
        formatter.groupingSeparator = "" //separador de miles etc cada tres numeros
        formatter.decimalSeparator = locale.decimalSeparator
        formatter.numberStyle = .decimal //acepte numeros deciames y no solo enteros
        formatter.maximumIntegerDigits = 100
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 100
        return formatter
    }()
    
    // Formateo De Valores Auxiliares para la parte cientifica
    private let auxTotalFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = "" //separador de miles etc cada tres numeros
        formatter.decimalSeparator = ""
        formatter.numberStyle = .decimal//acepte numeros deciames y no solo enteros
        formatter.maximumIntegerDigits = 100
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 100
        return formatter
    }()
    
    // Formateo de valores por pantalla por defecto (modifica visualmente el numero para mostrarlo en pantalla)
    private let printFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        let locale = Locale.current
        formatter.groupingSeparator = locale.groupingSeparator
        formatter.decimalSeparator = locale.decimalSeparator
        formatter.numberStyle = .decimal
        formatter.maximumIntegerDigits = 9 //maximo de numeros enteros de 9 digitos
        formatter.minimumFractionDigits = 0 //podemos no tener numeros decimales
        formatter.maximumFractionDigits = 8 //maximo de numeros decimales
        return formatter
    }()
    
    // Formateo De Valores Por Pantalla En Formato Cientifico Con Exponencial
    private let printScientificFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .scientific
        formatter.maximumFractionDigits = 3
        formatter.exponentSymbol = "e"
        return formatter
    }()
    
    //MARK: - Ciclo De Vida
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //esto es para ver si es , o . de acuerdo al pais donde se opere
        numberDecimal.setTitle(kDecimalSeparator, for: .normal)
        
        //recupera el valor de momeria al volver a iniciar la aplicacion
        total = UserDefaults.standard.double(forKey: kTotal)
        
        //mostrar el resultado inicial
        result()
    }
    override func viewDidAppear(_ animated: Bool) { //para el ipad
        super.viewDidAppear(animated)
        //Extension UIButton (Carpeta Util)
        //Botones numeros redondos
        number0.round()
        number1.round()
        number2.round()
        number3.round()
        number4.round()
        number5.round()
        number6.round()
        number7.round()
        number8.round()
        number9.round()
        numberDecimal.round()
        
        
        //Botones operadores redondos
        operatorAC.round()
        operatorPlusMinus.round()
        operatorPorcent.round()
        operatorResult.round()
        operatorAddition.round()
        operatorSubstraction.round()
        operatorMultiplication.round()
        operatorDivision.round()
        
    }
    
    //MARK: - Button Actions
    @IBAction func operatorACAction(_ sender: UIButton) {
        clear()
        sender.shine()//Brillo a los botonoes al hacer click
    }
    
    @IBAction func operatorPlusMinusAction(_ sender: UIButton) {
        temp = temp * (-1)//cambia los valores de signo
        //mostrar el dato en pantalla
        resultLabel.text = printFormatter.string(from: NSNumber(value: temp))
        sender.shine()//Brillo a los botonoes al hacer click
    }
    
    @IBAction func operatorPorcentAction(_ sender: UIButton) {
        //esto es cuando no se ah terminado la operacion y dan click en operador de porcentaje
        if operation != .porcent {
            result()
        }
        operating = true
        operation = .porcent
        result() //se llama resultado porque ahi esta como se debe resolver el operador
        sender.shine()//Brillo a los botonoes al hacer click
    }
    
    @IBAction func operatorResultAction(_ sender: UIButton) {
        result()
        sender.shine()//Brillo a los botonoes al hacer click
    }
    
    @IBAction func operatorAdditionAction(_ sender: UIButton) {
        //obligar a finalizar la operacion que se estaba ejecutando antes de comenzar esta
        if operation != .none {
            result()
        }
        
        operating = true
        operation = .addiction
        sender.selectOperation(true)//seleccion de button
        sender.shine()//Brillo a los botonoes al hacer click
    }
    
    @IBAction func operatorSubstractionAction(_ sender: UIButton) {
        //obligar a finalizar la operacion que se estaba ejecutando antes de comenzar esta
        if operation != .none {
            result()
        }
        
        operating = true
        operation = .substraction
        sender.selectOperation(true)//seleccion de button
        sender.shine()//Brillo a los botonoes al hacer click
    }
    
    @IBAction func operatorMultiplicationAction(_ sender: UIButton) {
        //obligar a finalizar la operacion que se estaba ejecutando antes de comenzar esta
        if operation != .none {
            result()
        }
        
        operating = true
        operation = .multiplication
        sender.selectOperation(true)//seleccion de button
        sender.shine()//Brillo a los botonoes al hacer click
    }
    
    @IBAction func operatorDivisionAction(_ sender: UIButton) {
        //obligar a finalizar la operacion que se estaba ejecutando antes de comenzar esta
        if operation != .none {
            result()
        }
        
        operating = true
        operation = .division
        sender.selectOperation(true)//seleccion de button
        sender.shine()//Brillo a los botonoes al hacer click
    }
    
    @IBAction func numberDecimalAction(_ sender: UIButton) {
        //esto es para que muestre los miles o millones de acuerdo al tamaño del numero que lo va ir haciendo temporalmente.
        let currentTemp = auxTotalFormatter.string(from: NSNumber(value: temp))!
        
        //comprobar si se esta realizando alguna operacion y para trabajar con numero maximo de decimales
        if !operating && currentTemp.count >= kMaxLength {
            return
        }
       
        //para colocar , o . a lo que esta en pantalla temp
        resultLabel.text = resultLabel.text! + kDecimalSeparator!
        decimal = true
        
        selectVisualOperation()//se observa cuando es seleccionado
        
        sender.shine()//Brillo a los botonoes al hacer click
    }
    @IBAction func numberAction(_ sender: UIButton) {
        //cambiar ac a c
        operatorAC.setTitle("C", for: .normal)
        
        var currentTemp = auxTotalFormatter.string(from: NSNumber(value: temp))!
        if !operating && currentTemp.count >= kMaxLength {
            return
        }
        
        currentTemp = auxFormatter.string(from: NSNumber(value: temp))!
        
        //Hemos seleccionado una operacion
        if operating {
            total = total == 0 ? temp : total //limpia resultados sin perderlos
            resultLabel.text = ""
            currentTemp = ""
            operating = false //se guardan los valores temp y limpiamos la pantalla
        }
        
        //Hemos seleccionado Decimales
        if decimal {
            currentTemp = "\(currentTemp)\(kDecimalSeparator!)"
            decimal = false //ya solucionado lo cerramos
        }
        
        //Nuevo valor por pantalla (temp)
        let number = sender.tag
        temp = Double(currentTemp + String(number))!
        resultLabel.text = printFormatter.string(from: NSNumber(value: temp))
        
        selectVisualOperation()//se observa cuando es seleccionado
        
        sender.shine()//Brillo a los botonoes al hacer click
        //tag es el numero que asociamos en cada button en propiedades ojo autoshrink para ajusta el tamaño y que quepa todo en el label con size
    
    }
    
    //limpia los valores (AC)
    private func clear() {
        operation = .none //se borra la operacion pendiente y queda en nada
        operatorAC.setTitle("AC", for: .normal)//cambia AC a C la app en operacion
        if temp != 0 { //vuelve los valores temporales a 0
            temp = 0
            resultLabel.text = "0"
        }else { //si el temportal e 0 solo existe un valor que es total y sera 0
            total = 0
            result()//reinicia la calculadora
        }
    }
    
    //Obtiene El Resultado Final
    private func result() {
        switch operation{
    //recordar que el valor temporal es que lo nostros digitamos en la calculadora
        case .none:
            //No hacemos nada
            break
        case .addiction:
            total = total + temp
            break
        case .substraction:
            total = total - temp
            break
        case .multiplication:
            total = total * temp
            break
        case .division:
            total = total / temp
            break
        case .porcent:
            temp = temp / 100
            total = temp
            break
        }
        
        //Formateo en pantalla
        
        if let currentTotal = auxTotalFormatter.string(from: NSNumber(value: total)), currentTotal.count > kMaxLength {
            resultLabel.text = printScientificFormatter.string(from: NSNumber(value: total))
        }else {
            resultLabel.text = printFormatter.string(from: NSNumber(value: total))
        }
        
        //recuperar la operancion que vuelva ser 0 re importante ya que antes no me cordadaba con los valores debido ah que seguia remotando la operacion de temp
        operation = .none
        
        selectVisualOperation()//deje de estar seleccionaod ya que no ahi operacion
        
        //guardado de datos simples en iOS
        UserDefaults.standard.set(total, forKey: kTotal)
        
        
        /*if total <= kMaxValue || total >= kMinValue {
            resultLabel.text = printFormatter.string(from: NSNumber(value: total))
        }*/
        
        print("TOTAL: \(total)")

    }
    
    //Muestra de forma visual la opercion seleccionada
    private func selectVisualOperation () {
        
        if !operating{
            //No estamos operando
            operatorAddition.selectOperation(false)
            operatorSubstraction.selectOperation(false)
            operatorMultiplication.selectOperation(false)
            operatorDivision.selectOperation(false)
        }else { //si estamos operando
            switch operation {
            case .none, .porcent:
                operatorAddition.selectOperation(false)
                operatorSubstraction.selectOperation(false)
                operatorMultiplication.selectOperation(false)
                operatorDivision.selectOperation(false)
                break
            case .addiction:
                operatorAddition.selectOperation(true)
                operatorSubstraction.selectOperation(false)
                operatorMultiplication.selectOperation(false)
                operatorDivision.selectOperation(false)
                break
            case .substraction:
                operatorAddition.selectOperation(false)
                operatorSubstraction.selectOperation(true)
                operatorMultiplication.selectOperation(false)
                operatorDivision.selectOperation(false)
                break
            case .multiplication:
                operatorAddition.selectOperation(false)
                operatorSubstraction.selectOperation(false)
                operatorMultiplication.selectOperation(true)
                operatorDivision.selectOperation(false)
                break
            case .division:
                operatorAddition.selectOperation(false)
                operatorSubstraction.selectOperation(false)
                operatorMultiplication.selectOperation(false)
                operatorDivision.selectOperation(true)
                break
            }
        }
    }

}

//
//  SQLite.swift
//  EasyLearn
//
//  Created by alex on 24.10.2019.
//  Copyright © 2019 Mezencev Aleksei. All rights reserved.
//

import Foundation

public class SQLDB{
    
  private var isDebug: Bool = {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }()
  private var dbFilePath: String?
  private var dbFolderPath: String?
  private let dateBaseFolder   = "DataBase"
  private let dataBaseFileName = "DataBase.sqlite"
  private let backupFolder     = "Backup"
  private var dataBase: FMDatabase?
  private let alertManeger     = AlertManager.shared
  static  let sharedInstance: SQLDB = SQLDB()
     
  private init(){
      
  }
 
  
  private func exist()-> Bool{
    let result = self.dataBase != nil
    if !result {
        alertManeger.showAlert(title: "Ошибка", message: "База данных не обнаружена!")
    }
    return result
  }
    
    public func openBase(){
        openOrCreateBase()
    }
    
    public func closeBase(){
        if dataBase != nil{
            let result = dataBase!.close()
            if !result {
                //Здесь обработаем ошибку закрытия БД
                alertManeger.showAlert(title: "Ошибка", message: "Ошибка работы с БД!")
                return
            }
            createBackup()
        }
    }
}







//MARK: ОБРАБОТКА ЗАПРОСОВ К БД
extension SQLDB {
    
    //Функция удаляет все таблицы из бд
    private func dropAllTables(){
        //Массив таблиц БД
        let arrayOfTables = ["ServiceTable"]
        var dropQuery:String
        
        for tableName in arrayOfTables {
            if self.exist() && dataBase!.tableExists(tableName){
                dropQuery = "Drop table \(tableName)"
              _ = self.executeUpdate(dropQuery, db: nil)
               }
            }
        }
    
    //Функция создает таблицу на основе переданного в параметре запроса
    private func CreateTable(query: String, errorLog: String?){
      if self.exist() && !self.executeUpdate(query, db: nil) {
          alertManeger.showAlert(title: "Ошибка", message: errorLog)
      }
    }
    
    //Функция создает индекс на основе переданного запроса
    private func CreateIndex(query: String){
      _ = self.executeUpdate(query, db: nil)
    }

    
    private func executeUpdate(_ query: String, db: FMDatabase?)-> Bool{
          var _db: FMDatabase
          if db == nil{
              guard dataBase != nil else { return false}
              _db = dataBase!
          }else{
              _db = db!
          }
          
          do{
              try _db.executeUpdate(query , values: nil)
              if isDebug {
                  NSLog("Запрос \"\(query)\" выполнен успешно!")
              }
              return true
          } catch {
              if isDebug {
                  NSLog("Ошибка выполнения запроса \"\(query)\" [ \(_db.lastErrorMessage()) ]")
              }
              return false
          }
    }
      
      private func executInTrasaction(querys:[String]) -> Bool{
         
            guard let db = dataBase else {return false}
            var result = true
            db.beginTransaction()
            for query in querys {
                 if !executeUpdate(query, db: db){
                     result = false
                 }
            }
             if result {
                 db.commit()
             }else{
                 db.rollback()
             }
             return result
        }
         
        private func executAsyncInTrasaction(querys:[String]){
         
             guard let _dbFilePath = dbFilePath else {return}
             let dbQueue = FMDatabaseQueue(path: _dbFilePath)
             
             if let queue = dbQueue {
                 queue.inTransaction { db, rollback in
                     do {
                         for query in querys {
                             try db.executeUpdate(query, values: nil)
                         }
                     } catch {
                         rollback.pointee = true
                         let _error = "\(error)"
                         self.alertManeger.showAlert(title: "Ошибка", message: _error)
                     }
                 }
                 queue.close()
             }
         }
}




//MARK: ИНИЦИАЛИЗАЦИЯ БД
extension SQLDB {
    
    //Функция создает все нужные таблицы в базе данных, вызывается при первом запуске приложения
    //
    private func CreateNewTables() {
      //Таблица иностранных слов
      let queryCreateWordTable = "CREATE TABLE IF NOT EXISTS WordTable (rowid INTEGER PRIMARY KEY AUTOINCREMENT, id varchar(36) UNIQUE, word varchar(30) NOT NULL, transcription varchar(30),partOfSpeech varchar(30), date REAL NOT NULL, language varchar(10))"

      let quaryIndexWordTable = "CREATE INDEX IF NOT EXISTS index_ID_WordTable ON WordTable (id)"
        
      let quaryIndexWordTable2 = "CREATE INDEX IF NOT EXISTS index_WORD_WordTable ON WordTable (word)"

      let queryCreatTranslateTable = "CREATE TABLE IF NOT EXISTS TranslateTable ( wordTranslate varchar(30) NOT NULL, language varchar(10), word_id varchar(36) NOT NULL, FOREIGN KEY (word_id) REFERENCES WordTable(id))"

      let quaryIndexTranslateTable = "CREATE INDEX IF NOT EXISTS index_WORDID_TranslateTable ON TranslateTable (word_id)"
      let quaryIndexTranslateTable2 = "CREATE INDEX IF NOT EXISTS index_WORDTRANSLATE_TranslateTable ON TranslateTable (wordTranslate)"

      let queryCreatRepeatWordsTable = "CREATE TABLE IF NOT EXISTS RepeatWordsTable ( date REAL NOT NULL, word_id varchar(36) NOT NULL, FOREIGN KEY (word_id) REFERENCES WordTable(id))"
      let quaryIndexRepeatWordsTable = "CREATE INDEX IF NOT EXISTS index_WORDID_RepeatWordsTable ON RepeatWordsTable (word_id)"
      
      let queryCreatWordsLearnStateTable = "CREATE TABLE IF NOT EXISTS WordsLearnStateTable ( state REAL NOT NULL, nextRepeatDate REAL NOT NULL, word_id varchar(36) NOT NULL, FOREIGN KEY (word_id) REFERENCES WordTable(id))"
      let quaryIndexWordsLearnStateTable = "CREATE INDEX IF NOT EXISTS index_WORDID_WordsLearnStateTable ON WordsLearnStateTable (word_id)"

        
        
      var querys = [String]()
      querys.append(queryCreateWordTable)
      querys.append(quaryIndexWordTable)
      querys.append(quaryIndexWordTable2)
      querys.append(queryCreatTranslateTable)
      querys.append(quaryIndexTranslateTable)
      querys.append(quaryIndexTranslateTable2)
      querys.append(queryCreatRepeatWordsTable)
      querys.append(quaryIndexRepeatWordsTable)
      querys.append(queryCreatWordsLearnStateTable)
      querys.append(quaryIndexWordsLearnStateTable)
      
      executAsyncInTrasaction(querys: querys)
    }
}




//MARK: ВНУТРЕННИЙ ИНТЕРФЕЙС ПО РАБОТЕ СО СЛОВАМИ
extension SQLDB {
    private func isWordinDB(_ word: String) -> Bool{
          guard let db = dataBase else {return false}
          let rsQuary: FMResultSet? = db.executeQuery("SELECT WordTable.word as word FROM WordTable as WordTable WHERE WordTable.word == '\(word)'", withArgumentsIn: [])
          var result = false
          
          if let _rsQuary = rsQuary{
              while _rsQuary.next() == true {
                  if let _word = _rsQuary.string(forColumn: "word") {
                    if _word.lowercased() == word.lowercased() {
                          result = true
                      }
                  }
              }
          }
          return result
      }
}




//MARK: ВНЕШНИЙ ИНТЕРФЕЙС ПО РАБОТЕ СО СЛОВАМИ
extension SQLDB {
    
    //Функция добавлет слово в БД если его еще нет
    func addWord(word: WordModel) -> Bool{
        //Проверим что слова еще нет в базе
        guard !isWordinDB(word.word) else {
            AlertManager.shared.showAlert(title: "Внимание!", message: "Слово \(word.word) уже есть в словоре")
            return false}
        var result = false
        var querys = [String]()
        let uuid = NSUUID().uuidString.lowercased()//пример: 68b696d7-320b-4402-a412-d9cee10fc6a3
        var transcription = ""
        if let _transcription = word.transcription{
            transcription = _transcription
        }
        var partOfSpeech = ""
        if let _partOfSpeech = word.partOfSpeech{
            partOfSpeech = _partOfSpeech
        }
        
        //Запрос по вставке самого слова
        querys.append("INSERT INTO WordTable (id, word, transcription, partOfSpeech, date, language) VALUES ('\(uuid)','\(word.word)','\(transcription)','\(partOfSpeech)','\(Date().timeIntervalSince1970)','\(word.wordLanguge)')")
        //Запросы по вставке перевода слова
        for translateWord in word.translateWords {
            querys.append("INSERT INTO TranslateTable (word_id, wordTranslate, language) VALUES ('\(uuid)','\(translateWord.word)','\(word.wordTranslateLanguge)')")
        }
        //Запрос по установке начального статуса изучения слова
        querys.append("INSERT INTO WordsLearnStateTable (word_id, state, nextRepeatDate) VALUES ('\(uuid)','\(0)','\(0)')")
        
        if executInTrasaction(querys:querys) {
            result = true
        }
            
        return result
    }

    
    //Функция получает одно слово из БД по наименованию на иностарнном языке
    func getWord(word: String) -> WordModel?{
        var result: WordModel? = nil
        if let _result = getWords(words: [word]) {
            result = _result[word]
        }
        return result
    }
    
    
    //Функция получает слова из бд по массиву слов на иностранном языке
    //
    func getWords(words: [String])-> [String : WordModel]?{
       guard let db = dataBase else {return nil}
       
       var wordsList = ""
        for v in words{
            if v != "" {
                wordsList = wordsList + (wordsList == "" ? "":", ") + "\(v)"
            }
        }
    
       let query = "SELECT WordTable.word as word,  WordTable.transcription as transcription, WordTable.partOfSpeech as partOfSpeech, WordTable.id as id,  WordTable.date as date,  WordTable.language as languageFrom, TranslateTable.wordTranslate as wordTranslate, TranslateTable.language as languageTo FROM WordTable as WordTable left OUTER join TranslateTable as TranslateTable on WordTable.id = TranslateTable.word_id WHERE WordTable.word in (" + wordsList + ")"
        
       let rsQuary: FMResultSet? = db.executeQuery(query, withArgumentsIn: [])
        
       guard let rs = rsQuary else {return nil}
       
       var result = [String : WordModel]()
        
       var word: String          = ""
       var transcription: String = ""
       var partOfSpeech: String  = ""
       var wordsTranslate        = [(word:String, partOfSpeech: String?)]()
       var languageFrom: String  = ""
       var languageTo: String    = ""
       var dateAdd: Date?
       var add = true

       while rs.next() == true {
            
            if let _word = rs.string(forColumn: "word") {
                //Добавим слово в результирующий словарь
                if _word != word && word != ""{
                    add = true // переменная нужна чтобы лишний раз не перезаписывать переменные одинаковые для слов перевода
                    let newWord = WordModel(word: word, translateWordsTupls: wordsTranslate, langugeFrom: languageFrom, LangugeTo: languageTo, date: dateAdd, transcription: transcription, partOfSpeech: partOfSpeech)
                    result[word] = newWord
                    wordsTranslate.removeAll()
                }
                word = _word
            }
        
            if add, let _transcription = rs.string(forColumn: "transcription") {
                transcription = _transcription
            }
        
            if add, let _partOfSpeech = rs.string(forColumn: "partOfSpeech") {
                partOfSpeech = _partOfSpeech
            }
        
            if add, let _languageFrom = rs.string(forColumn: "languageFrom") {
                languageFrom = _languageFrom
            }
        
            if add, let _languageTo = rs.string(forColumn: "languageTo") {
                languageTo = _languageTo
            }
        
            if add {
                let dateDouble = rs.double(forColumn: "date")
                if let date = dateDouble.date(){
                    dateAdd = date
                }else {
                    dateAdd = Date(timeIntervalSince1970: dateDouble)
                }
            }
        
            if let _wordTranslate = rs.string(forColumn: "wordTranslate") {
                let tr:(word:String, partOfSpeech: String?) = (_wordTranslate,  nil)
                wordsTranslate.append(tr)
            }
            add = false
        }
       let newWord = WordModel(word: word, translateWordsTupls: wordsTranslate, langugeFrom: languageFrom, LangugeTo: languageTo, date: dateAdd, transcription: transcription, partOfSpeech: partOfSpeech)
       result[word] = newWord
        
       return result
    }


    func getAllAWords(sort: TypeOfSortWords) -> [String : WordModel]? {
        guard let db = self.dataBase else {return nil}
           
           var sortString = " Order by "
            switch sort {
            case .abc:
                sortString = sortString + "WordTable.word"
            case .addTime:
                sortString = sortString + "WordTable.date"
            case .repeatTime: //Доделать потом
                sortString = ""
            }
        
           let query = "SELECT WordTable.word as word, WordTable.transcription as transcription, WordTable.partOfSpeech as partOfSpeech, WordTable.id as id,  WordTable.date as date,  WordTable.language as languageFrom, TranslateTable.wordTranslate as wordTranslate, TranslateTable.language as languageTo FROM WordTable as WordTable left OUTER join TranslateTable as TranslateTable on WordTable.id = TranslateTable.word_id" + sortString
            
           let rsQuary: FMResultSet? = db.executeQuery(query, withArgumentsIn: [])
            
           guard let rs = rsQuary else {return nil}
           
           var result = [String : WordModel]()
            
           var word: String         = ""
           var transcription: String = ""
           var partOfSpeech: String  = ""
           var wordsTranslate       = [(word:String, partOfSpeech: String?)]()
           var languageFrom: String = ""
           var languageTo: String   = ""
           var dateAdd: Date?
           var add = true
           var isEmpty = true

           while rs.next() == true {
                isEmpty = false
                if let _word = rs.string(forColumn: "word") {
                    //Добавим слово в результирующий словарь
                    if _word != word && word != ""{
                        add = true // переменная нужна чтобы лишний раз не перезаписывать переменные одинаковые для слов перевода
                        let newWord = WordModel(word: word, translateWordsTupls: wordsTranslate, langugeFrom: languageFrom, LangugeTo: languageTo, date: dateAdd, transcription: transcription, partOfSpeech: partOfSpeech)
                        result[word] = newWord
                        wordsTranslate.removeAll()
                    }
                    word = _word
                }
            
                if add, let _transcription = rs.string(forColumn: "transcription") {
                    transcription = _transcription
                }
            
                if add, let _partOfSpeech = rs.string(forColumn: "partOfSpeech") {
                    partOfSpeech = _partOfSpeech
                }
            
                if add, let _languageFrom = rs.string(forColumn: "languageFrom") {
                    languageFrom = _languageFrom
                }
            
            
                if add, let _languageTo = rs.string(forColumn: "languageTo") {
                    languageTo = _languageTo
                }
            
                if add {
                    let dateDouble = rs.double(forColumn: "date")
                    if let date = dateDouble.date(){
                        dateAdd = date
                    }
                }
            
                if let _wordTranslate = rs.string(forColumn: "wordTranslate") {
                    let tr:(word:String, partOfSpeech: String?) = (_wordTranslate,  nil)
                    wordsTranslate.append(tr)
                }
                add = false
            }
            if !isEmpty {
                let newWord = WordModel(word: word, translateWordsTupls: wordsTranslate, langugeFrom: languageFrom, LangugeTo: languageTo, date: dateAdd, transcription: transcription, partOfSpeech: partOfSpeech)
                result[word] = newWord
            }
           
           return result
        }
    
    
    func getWordForLearn(count: Int, complitionHandler: @escaping(_ wordModel: ([WordModel])?)->()){
           guard let db = dataBase else {complitionHandler(nil); return}
        
           let query = "SELECT WordTable.word as word,  WordTable.transcription as transcription, WordTable.partOfSpeech as partOfSpeech, WordTable.id as id,  WordTable.date as date,  WordTable.language as languageFrom, TranslateTable.wordTranslate as wordTranslate, TranslateTable.language as languageTo FROM WordTable as WordTable left OUTER join TranslateTable as TranslateTable on WordTable.id = TranslateTable.word_id WHERE WordTable.id in ( SELECT WLST.word_id FROM WordsLearnStateTable as WLST where WLST.state < 100 order by WLST.state LIMIT \(count)) order by WordTable.word"
            
           let rsQuary: FMResultSet? = db.executeQuery(query, withArgumentsIn: [])
            
           guard let rs = rsQuary else {complitionHandler(nil); return}
           
           var result = [WordModel]()
            
           var word: String          = ""
           var transcription: String = ""
           var partOfSpeech: String  = ""
           var wordsTranslate        = [(word:String, partOfSpeech: String?)]()
           var languageFrom: String  = ""
           var languageTo: String    = ""
           var dateAdd: Date?
           var add = true

           while rs.next() == true {
                
                if let _word = rs.string(forColumn: "word") {
                    //Добавим слово в результирующий словарь
                    if _word != word && word != ""{
                        add = true // переменная нужна чтобы лишний раз не перезаписывать переменные одинаковые для слов перевода
                        let newWord = WordModel(word: word, translateWordsTupls: wordsTranslate, langugeFrom: languageFrom, LangugeTo: languageTo, date: dateAdd, transcription: transcription, partOfSpeech: partOfSpeech)
                        result.append(newWord)
                        wordsTranslate.removeAll()
                    }
                    word = _word
                }
            
                if add, let _transcription = rs.string(forColumn: "transcription") {
                    transcription = _transcription
                }
            
                if add, let _partOfSpeech = rs.string(forColumn: "partOfSpeech") {
                    partOfSpeech = _partOfSpeech
                }
            
                if add, let _languageFrom = rs.string(forColumn: "languageFrom") {
                    languageFrom = _languageFrom
                }
            
                if add, let _languageTo = rs.string(forColumn: "languageTo") {
                    languageTo = _languageTo
                }
            
                if add {
                    let dateDouble = rs.double(forColumn: "date")
                    if let date = dateDouble.date(){
                        dateAdd = date
                    }else {
                        dateAdd = Date(timeIntervalSince1970: dateDouble)
                    }
                }
            
                if let _wordTranslate = rs.string(forColumn: "wordTranslate") {
                    let tr:(word:String, partOfSpeech: String?) = (_wordTranslate,  nil)
                    wordsTranslate.append(tr)
                }
                add = false
            }
           let newWord = WordModel(word: word, translateWordsTupls: wordsTranslate, langugeFrom: languageFrom, LangugeTo: languageTo, date: dateAdd, transcription: transcription, partOfSpeech: partOfSpeech)
           result.append(newWord)
            
           complitionHandler(result)
        }
    
}



//MARK: РАБОТА С ФАЙЛАМИ
extension SQLDB {
    
    private func openOrCreateBase(){

        let fManeger = FileManager.default
        findOrCreateFileDB(fManeger)
        //Создадим бэкап в фоне
        let queue = DispatchQueue.global(qos: .utility)
        queue.async{
            self.createBackup()
        }
        guard let _dbFilePath = dbFilePath else {return}
        
        dataBase = FMDatabase(path: _dbFilePath)
        if let db = dataBase{
            guard db.open() else {
                                  alertManeger.showAlert(title: "Ошибка", message: "Что то пошло не так при открытии базы данных")
                                  return}

            //Если при открытии базы не обнаружили сервисную таблицу то считаем это первым запуском и создаем все табоицы
            if !db.tableExists("WordTable") {
                CreateNewTables()
            }
        }
    }
    
    private func getBackupFolder()->String{
        if dbFolderPath != nil {
            return dbFolderPath! + "/" + backupFolder
        }
        return ""
    }
    
    private func findOrCreateFileDB(_ fManeger:FileManager){
        let libraryDirectoryPath = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0]
        let folder = createFolderDB(parentFolder:libraryDirectoryPath, fManeger:fManeger)
        if  folder != ""{
            let dbfile = folder + "/" + dataBaseFileName
            if !fManeger.fileExists(atPath: dbfile){
                creatFileIfNotExist(folder: folder,fManeger:fManeger)
            }else{
                dbFilePath = dbfile
            }
        }
    }
    
    private func creatFileIfNotExist(folder:String, fManeger:FileManager){
        if fManeger.fileExists(atPath: folder + "/" + dataBaseFileName){
            return
        }else{
            if let url = URL(string: folder){
                let resultURL = url.appendingPathComponent(dataBaseFileName)

                if !FileManager.default.isReadableFile(atPath: resultURL.path){
                    dbFilePath = resultURL.path
                }
            }else{
                alertManeger.showAlert(title: "Ошибка", message: "Не удалось содать папку для базы данных")
          }
        }
    }
    
    private func createFolderDB(parentFolder:String, fManeger:FileManager)->String{
        if parentFolder != "" {
            let folderName = parentFolder+"/DataBase"
            if fManeger.fileExists(atPath: folderName){
                if self.dbFolderPath == nil {
                    self.dbFolderPath = folderName
                }
                return folderName
            }else{
                do{
                try fManeger.createDirectory(atPath: folderName, withIntermediateDirectories: false, attributes: nil)
                }catch{
                  if isDebug{
                    NSLog(error.localizedDescription)
                  }
                }
                if fManeger.fileExists(atPath: folderName){
                    self.dbFolderPath = folderName
                    return folderName
                }else{
                    return ""
                }
            }
        }
        return ""
    }
    
    //Функция копирует файл бд в папку бэкапов
    private func createBackup(){
        //return
        //Проверка настроек надо не надо делать бэкап
      guard let result = SettingsModel.getSetting(setting: "Use auto backup", defaultValue: false)  else { return }
      if result is Bool && !(result as! Bool){
          return
      }

        let backupFolder = getBackupFolder()
        if backupFolder != "" {
            let fManeger = FileManager.default
          let fileName = "Backup_" + Date().textFromeDateWithFormat(format: "dd_MM_yy") + ".sqlite"
            let backupFilePath = backupFolder + "/" + fileName
            if !fManeger.fileExists(atPath:backupFilePath) {
                if dbFilePath != nil && fManeger.fileExists(atPath: dbFilePath!){
                    if !fManeger.fileExists(atPath:backupFolder){
                        do{
                            try fManeger.createDirectory(atPath: backupFolder, withIntermediateDirectories: false, attributes: nil)
                        }catch{
                        }
                    }
                    copyFile(fromPath:dbFilePath!, toPath:backupFilePath)
                    removOldBackup(false)
                }
            }else{
                //Обновим бэкап по окончанию работы
                do{
                    //В начале удалим старый
                    try fManeger.removeItem(atPath: backupFilePath)
                    copyFile(fromPath:dbFilePath!, toPath:backupFilePath)
                }catch{
                    NSLog(error.localizedDescription)
                }
            }
        }
    }
    
    private func copyFile(fromPath:String, toPath:String){
        let CreateAttributes = [FileAttributeKey.creationDate: Date()]
        let MdificationAttributes = [FileAttributeKey.modificationDate: Date()]
        do {
            try FileManager.default.copyItem(atPath: fromPath, toPath: toPath)
            try FileManager.default.setAttributes(CreateAttributes, ofItemAtPath: toPath)
            try FileManager.default.setAttributes(MdificationAttributes, ofItemAtPath: toPath)
        }
        catch
        {
            print(error)
        }
    }
    
    //удаляем последние бэкапы по дате создания самые ранние пока не дойдем до нужного количества
    private func removOldBackup(_ async: Bool){
        if async {
        let queue = DispatchQueue.global(qos: .utility)
            queue.async{
                self.removeInBackground()
            }
        }else{
            self.removeInBackground()
        }
    }
    
    private func removeInBackground(){
      let backupCount = (SettingsModel.getSetting(setting: "Backup count", defaultValue: 1) as! Int)
        
        let bFolder = self.dbFolderPath! + "/" + self.backupFolder
        let arrayOfPathBackup = self.getSortedArrayOfBackUpFiles(folderPath: bFolder)
        if arrayOfPathBackup.count > backupCount {
        var count = arrayOfPathBackup.count
        while count > backupCount {
            do{
                try FileManager.default.removeItem(atPath: bFolder+"/"+arrayOfPathBackup[0])
            }catch{
                return
            }
                count  = count - 1
            }
        }
    }
    
    private func getSortedArrayOfBackUpFiles(folderPath:String)->[String]{
        let directory = URL(fileURLWithPath: folderPath, isDirectory: true)
        if let urlArray = try? FileManager.default.contentsOfDirectory(at: directory,
                                                                       includingPropertiesForKeys: [.contentModificationDateKey],
                                                                       options:.skipsHiddenFiles) {

           return urlArray.map { url in
                (url.lastPathComponent, (try? url.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? Date.distantPast)
                }
                .sorted(by: { $0.1 < $1.1 }).map{ $0.0 }
            
        } else {
            return [String]()
        }
    }
    
    //Процедура копирует файл бэкапа в папку рабочей базы
    private func restoreBackup(backupFile:String) -> String?{
        if FileManager.default.fileExists(atPath:backupFile)
        && FileManager.default.fileExists(atPath:dbFilePath!){
            do{
                if dataBase != nil {
                    dataBase?.close()
                }
                try FileManager.default.removeItem(atPath: dbFilePath!)
                try FileManager.default.copyItem(atPath: backupFile, toPath: dbFilePath!)
                self.dataBase = nil
                openBase()
                return nil
            }catch{
                return "При восстановлении данных что то пошло не так :("
            }
        }
        return "При восстановлении данных что то пошло не так :("
    }
}

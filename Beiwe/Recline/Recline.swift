//
//  Recline.swift
//  Beiwe
//
//  Created by Keary Griffin on 3/28/16.
//  Copyright © 2016 Rocketfarm Studios. All rights reserved.
//
//  Debuged and modified by Zexing Gao on 06/10/18.
//


import Foundation
import PromiseKit
import ObjectMapper

class ReclineObject : Mappable {
    fileprivate var _id: String?

    init() {
    }

    required init?(map: Map) {
    }

    // Mappable
    func mapping(map: Map) {
    }

}

struct ReclineMetadata : Mappable {
    var type: String?;

    init(type: String) {
        self.type = type;
    }
    init?(map: Map) {

    }

    mutating func mapping(map: Map) {
        type        <- map["type"];
    }
}
enum ReclineErrors: Error {
    case databaseNotOpen
}
class Recline {
    static let kReclineMetadataKey = "reclineMetadata";
    static let queue = DispatchQueue(label: "com.rocketfarm.beiwe.recline.queue", attributes: [])
    static let shared = Recline();
    var manager: CBLManager!;
    var db: CBLDatabase?;
    var typesView: CBLView?;

    init() {
    }

    func _open(_ dbName: String = "default") -> Promise<Bool> {
        return Promise { resolve, reject in
            self.db = try manager.databaseNamed(dbName);
            self.typesView = self.db!.viewNamed("reclineType")
            typesView!.setMapBlock({ (doc, emit) in
                if let reclineMeta = Mapper<ReclineMetadata>().map(JSONObject: doc[Recline.kReclineMetadataKey]) {
                    if let type = reclineMeta.type {
                        emit(type, Mapper<ReclineMetadata>().toJSON(reclineMeta));
                    }
                }
            }, version: "5")

            return resolve(true);
        }
    }

    func open(_ dbName: String = "default") -> Promise<Bool> {
        return Promise().then(on: Recline.queue) {
            if (self.manager == nil) {
                let cbloptions = CBLManagerOptions(readOnly: false, fileProtection: NSData.WritingOptions.noFileProtection)
                let poptions=UnsafeMutablePointer<CBLManagerOptions>.allocate(capacity: 1)
                poptions.initialize(to: cbloptions)
                try self.manager = CBLManager(directory: CBLManager.defaultDirectory(), options: poptions)
                self.manager.dispatchQueue = Recline.queue
            }

            return self._open(dbName);
        }
    }

    func _save<T: ReclineObject>(_ obj: T) -> Promise<T> {
        return Promise { resolve, reject in
            guard let db = db else {
                return reject(ReclineErrors.databaseNotOpen);
            }

            var doc: CBLDocument?
            if let _id = obj._id {
                doc = db.document(withID: _id)
            } else {
                doc = db.createDocument()
            }

            var newProps = Mapper<T>().toJSON(obj);
            let reclineMeta = ReclineMetadata(type: String(describing: type(of: obj)));
            newProps[Recline.kReclineMetadataKey] = Mapper<ReclineMetadata>().toJSON(reclineMeta);
            newProps["_id"] = doc?.properties?["_id"]
            newProps["_rev"] = doc?.properties?["_rev"]
            try doc?.putProperties(newProps)

            return resolve(obj);

        }

    }

    func save<T: ReclineObject>(_ obj: T) -> Promise<T> {
        return Promise().then(on: Recline.queue) {
            return self._save(obj)
        }
    }


    func _load<T: ReclineObject>(_ docId: String) -> Promise<T?> {
        return Promise { resolve, reject in
            guard let db = db else {
                return reject(ReclineErrors.databaseNotOpen);
            }
            let doc: CBLDocument? = db.document(withID: docId);
            if let doc = doc {
                if let newObj = Mapper<T>().map(JSONObject: doc.properties)  {
                    newObj._id = doc.properties?["_id"] as? String
                    return resolve(newObj);
                }
            }
            return resolve(nil);
        }
    }

    func load<T: ReclineObject>(_ docId: String) -> Promise<T?> {
        return Promise().then(on: Recline.queue) {
            self._load(docId);
        }
    }


    func _queryAll<T: ReclineObject>() -> Promise<[T]> {
        return Promise { resolve, reject in
            guard let typesView = typesView else {
                return reject(ReclineErrors.databaseNotOpen);
            }

            let query = typesView.createQuery();
            let result = try query.run();
            var promises: [Promise<T?>] = [];
            while let row = result.nextRow() {
                if let docId = row.documentID {
                    promises.append(load(docId))
                }
            }
            when(fulfilled: promises).then(on: Recline.queue)  { results -> Void in
                //resolve([]);
                resolve(results.filter { $0 != nil}.map { $0! }  );
                }.catch { err in
                    reject(err)
                }
            
        }

    }

    func queryAll<T: ReclineObject>() -> Promise<[T]> {
        return Promise().then(on: Recline.queue) {
            return self._queryAll()
        }
    }


    func _purge<T: ReclineObject>(_ obj: T) -> Promise<Bool> {
        return Promise { resolve, reject in

            if let _id = obj._id {
                try db?.document(withID: _id)?.purgeDocument()
                return resolve(true);
            } else {
                return resolve(true);
            }

        }
        
    }

    func purge<T: ReclineObject>(_ obj: T) -> Promise<Bool> {
        return Promise().then(on: Recline.queue) {
            return self._purge(obj)
        }
    }

    func compact() -> Promise<Void> {
        return Promise<Void>().then(on: Recline.queue) { _ -> Void in
            try self.db?.compact()
            }
    }

}

import Foundation
import Sourceful

public class SQLiteLexer: SourceCodeRegexLexer {
    
    public init() {}
    
    lazy var generators: [TokenGenerator] = {
        
        var generators = [TokenGenerator?]()
        
//        generators.append(regexGenerator)
        
        let keywords = "ABORT ACTION ADD AFTER ALL ALTER ALWAYS ANALYZE AND AS ASC ATTACH AUTOINCREMENT BEFORE BEGIN BETWEEN BY CASCADE CASE CAST CHECK COLLATE COLUMN COMMIT CONFLICT CONSTRAINT CREATE CROSS CURRENT CURRENT_DATE CURRENT_TIME CURRENT_TIMESTAMP DATABASE DEFAULT DEFERRABLE DEFERRED DELETE DESC DETACH DISTINCT DO DROP EACH ELSE END ESCAPE EXCEPT EXCLUDE EXCLUSIVE EXISTS EXPLAIN FAIL FILTER FIRST FOLLOWING FOR FOREIGN FROM FULL GENERATED GLOB GROUP GROUPS HAVING IF IGNORE IMMEDIATE IN INDEX INDEXED INITIALLY INNER INSERT INSTEAD INTERSECT INTO IS ISNULL JOIN KEY LAST LEFT LIKE LIMIT MATCH MATERIALIZED NATURAL NO NOT NOTHING NOTNULL NULL NULLS OF OFFSET ON OR ORDER OTHERS OUTER OVER PARTITION PLAN PRAGMA PRECEDING PRIMARY QUERY RAISE RANGE RECURSIVE REFERENCES REGEXP REINDEX RELEASE RENAME REPLACE RESTRICT RETURNING RIGHT ROLLBACK ROW ROWS SAVEPOINT SELECT SET TABLE TEMP TEMPORARY THEN TIES TO TRANSACTION TRIGGER UNBOUNDED UNION UNIQUE UPDATE USING VACUUM VALUES VIEW VIRTUAL WHEN WHERE WINDOW WITH WITHOUT"
        generators.append(
            keywordGenerator(keywords.components(separatedBy: " "),
                             tokenType: .keyword))
        generators.append(
            keywordGenerator(keywords.lowercased().components(separatedBy: " "),
                             tokenType: .keyword))
        
        let buildInScalarFn = "abs changes char coalesce format glob hex ifnull iif instr last_insert_rowid length like like likelihood likely load_extension load_extension lower ltrim ltrim max min nullif printf quote random randomblob replace round round rtrim rtrim sign soundex sqlite_compileoption_get sqlite_compileoption_used sqlite_offset sqlite_source_id sqlite_version substr substr substring substring total_changes trim trim typeof unicode unlikely upper zeroblob date time datetime julianday unixepoch strftime avg count count group_concat group_concat max min sum total row_number rank dense_rank percent_rank cume_dist ntile lag lead first_value last_value nth_value acos acosh asin asinh atan atan2 atanh ceil ceiling cos cosh degrees exp floor ln log log log10 log2 mod pi pow power radians sin sinh sqrt tan tanh trunc json json_array json_array_length json_array_length json_extract json_insert json_object json_patch json_remove json_replace json_set json_type json_type json_valid json_quote json_group_array json_group_object json_each json_each json_tree json_tree"

        generators.append(
            keywordGenerator(buildInScalarFn.components(separatedBy: " "),
                             tokenType: .identifier))
        generators.append(
            keywordGenerator(buildInScalarFn.uppercased().components(separatedBy: " "),
                             tokenType: .identifier))
        
        let buildType = "null integer real text blob"
        
        generators.append(
            keywordGenerator(buildType.components(separatedBy: " "), tokenType: .string))
        
        generators.append(
            keywordGenerator(buildType.uppercased().components(separatedBy: " "), tokenType: .string))
        
        // Line comment
        generators.append(regexGenerator("--(.*)", tokenType: .comment))
        
        // Block comment
        generators.append(regexGenerator("(/\\*)(.*)(\\*/)", options: [.dotMatchesLineSeparators], tokenType: .comment))

        
        return generators.compactMap({ $0 })
    }()
    
    public func generators(source: String) -> [TokenGenerator] {
        return generators
    }
}

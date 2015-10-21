//
//  ViewController.m
//  sqlit3
//
//  Created by 栾有数 on 15/10/21.
//  Copyright © 2015年 栾有数. All rights reserved.
//

#import "ViewController.h"
#import <sqlite3.h>
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *ageTextField;
@property (weak, nonatomic) IBOutlet UITextField *sexTextField;
@property (weak, nonatomic) IBOutlet UITextField *weightTextField;
@property (weak, nonatomic) IBOutlet UITextField *addressTextField;

@end

@implementation ViewController
-(NSString *) dataFilePath{
    
    NSArray *path =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *document = [path objectAtIndex:0];
    
    return [document stringByAppendingPathComponent:@"data.sqlite"];//'persion.sqlite'
    
}
- (IBAction)search:(id)sender {
    sqlite3 * database;
    
    if (sqlite3_open([[self dataFilePath] UTF8String], &database)!=SQLITE_OK) {
            sqlite3_close(database);
            NSAssert(0, @"open database faid!");
            NSLog(@"数据库创建失败！");
        }
    NSAssert(database, @"打开失败");
    
//    NSString *quary = @"SELECT * FROM PERSIONINFO WHERE NAME = ";//SELECT ROW,FIELD_DATA FROM FIELDS ORDER BY ROW
    NSString *quary = [NSString stringWithFormat:@"SELECT * FROM PERSIONINFO WHERE NAME = '%@'",self.nameTextField.text];
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(database, [quary UTF8String], -1, &stmt, nil) == SQLITE_OK) {
        
        while (sqlite3_step(stmt)==SQLITE_ROW) {
            
            char *name = (char *)sqlite3_column_text(stmt, 1);
            NSString *nameString = [[NSString alloc] initWithUTF8String:name];
            self.nameTextField.text = nameString;
            
            int age = sqlite3_column_int(stmt, 2);
            self.ageTextField.text = [NSString stringWithFormat:@"%d",age];
            
            char *sex = (char *)sqlite3_column_text(stmt, 3);
            NSString *sexString = [[NSString alloc] initWithUTF8String:sex];
            self.sexTextField.text = sexString;
            
            int weight = sqlite3_column_int(stmt, 4);
            self.weightTextField.text = [NSString stringWithFormat:@"%d",weight];
            
            
            char *address = (char *)sqlite3_column_text(stmt, 5);
            NSString *addressString = [[NSString alloc] initWithUTF8String:address];
            self.addressTextField.text = addressString;
            
        }
        
        sqlite3_finalize(stmt);
    }
    //用完了一定记得关闭，释放内存
        sqlite3_close(database);

}
- (IBAction)creattable:(id)sender {
    //创建
    sqlite3 *database;
    
    if (sqlite3_open([[self dataFilePath] UTF8String], &database)!=SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"open database faid!");
        NSLog(@"数据库创建失败！");
    }
    NSAssert(database, @"打开失败");
    
    if (sqlite3_open([[self dataFilePath] UTF8String], &database)!=SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"open database faid!");
        NSLog(@"数据库创建失败！");
    }
    //插入一张表/PERSIONINFO表
    NSString *ceateSQL = @"CREATE TABLE IF NOT EXISTS PERSIONINFO(ID INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT, AGE INTEGER, SEX TEXT, WEIGHT INTEGER, ADDRESS TEXT)";
    
    char *ERROR;
    
    if (sqlite3_exec(database, [ceateSQL UTF8String], NULL, NULL, &ERROR)!=SQLITE_OK){
        sqlite3_close(database);
        NSAssert(0, @"ceate table faild!");
        NSLog(@"表创建失败");
    }
    sqlite3_close(database);
}
- (IBAction)update:(id)sender {
    //更新
    sqlite3 * database;
    
    if (sqlite3_open([[self dataFilePath] UTF8String], &database)!=SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"open database faid!");
        NSLog(@"数据库创建失败！");
    }
    NSAssert(database, @"打开失败");
    
    char *update = "INSERT OR REPLACE INTO PERSIONINFO(NAME,AGE,SEX,WEIGHT,ADDRESS)""VALUES(?,?,?,?,?);";
    //上边的update也可以这样写：
    //NSString *insert = [NSString stringWithFormat:@"INSERT OR REPLACE INTO PERSIONINFO('%@','%@','%@','%@','%@')VALUES(?,?,?,?,?)",NAME,AGE,SEX,WEIGHT,ADDRESS];
    
    char *errorMsg = NULL;
    sqlite3_stmt * stmt;
    if (sqlite3_prepare_v2(database, update, -1, &stmt, nil) == SQLITE_OK) {
        
        //【插入数据】在这里我们使用绑定数据的方法，参数一：sqlite3_stmt，参数二：插入列号，参数三：插入的数据，参数四：数据长度（-1代表全部），参数五：是否需要回调
        sqlite3_bind_text(stmt, 1, [self.nameTextField.text UTF8String], -1, NULL);
        sqlite3_bind_int(stmt, 2, [self.ageTextField.text intValue]);
        sqlite3_bind_text(stmt, 3, [self.sexTextField.text UTF8String], -1, NULL);
        sqlite3_bind_int(stmt, 4, [self.weightTextField.text integerValue]);
        sqlite3_bind_text(stmt, 5, [self.addressTextField.text UTF8String], -1, NULL);
    }
    if (sqlite3_step(stmt) != SQLITE_DONE)
        NSLog(@"数据更新失败");
    //    NSAssert(0, @"error updating :%s",errorMsg);
    
    sqlite3_finalize(stmt);
    
    sqlite3_close(database);

}
- (IBAction)insert:(id)sender {
    //插入,persioninfo
    sqlite3 * database;
    
    if (sqlite3_open([[self dataFilePath] UTF8String], &database)!=SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"open database faid!");
        NSLog(@"数据库创建失败！");
    }
    NSAssert(database, @"打开失败");
    
    char *errorMsg = NULL;
//    NSString *insert = [NSString stringWithFormat:@"INSERT OR REPLACE INTO PERSIONINFO('%@','%@','%@','%@','%@')VALUES('%@','%d','%@','%d','%@')",@"NAME",@"AGE",@"SEX",@"WEIGHT",@"ADDRESS",@"小杨",23,@"man",65,@"中国北京,haidian,shangdi,xinxiRoad,100014"];
     NSString *insert = [NSString stringWithFormat:@"INSERT OR REPLACE INTO PERSIONINFO('%@','%@','%@','%@','%@')VALUES('%@','%d','%@','%d','%@')",@"NAME",@"AGE",@"SEX",@"WEIGHT",@"ADDRESS",self.nameTextField.text,[self.ageTextField.text intValue] ,self.sexTextField.text,[self.weightTextField.text intValue],self.addressTextField.text];
    
    //执行语句
    if (sqlite3_exec(database, [insert UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(database);
    }

}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//#define SQLITE_OK           0   /* 成功 | Successful result */
//    /* 错误码开始 */
//#define SQLITE_ERROR        1   /* SQL错误 或 丢失数据库 | SQL error or missing database */
//#define SQLITE_INTERNAL     2   /* SQLite 内部逻辑错误 | Internal logic error in SQLite */
//#define SQLITE_PERM         3   /* 拒绝访问 | Access permission denied */
//#define SQLITE_ABORT        4   /* 回调函数请求取消操作 | Callback routine requested an abort */
//#define SQLITE_BUSY         5   /* 数据库文件被锁定 | The database file is locked */
//#define SQLITE_LOCKED       6   /* 数据库中的一个表被锁定 | A table in the database is locked */
//#define SQLITE_NOMEM        7   /* 某次 malloc() 函数调用失败 | A malloc() failed */
//#define SQLITE_READONLY     8   /* 尝试写入一个只读数据库 | Attempt to write a readonly database */
//#define SQLITE_INTERRUPT    9   /* 操作被 sqlite3_interupt() 函数中断 | Operation terminated by sqlite3_interrupt() */
//#define SQLITE_IOERR       10   /* 发生某些磁盘 I/O 错误 | Some kind of disk I/O error occurred */
//#define SQLITE_CORRUPT     11   /* 数据库磁盘映像不正确 | The database disk image is malformed */
//#define SQLITE_NOTFOUND    12   /* sqlite3_file_control() 中出现未知操作数 | Unknown opcode in sqlite3_file_control() */
//#define SQLITE_FULL        13   /* 因为数据库满导致插入失败 | Insertion failed because database is full */
//#define SQLITE_CANTOPEN    14   /* 无法打开数据库文件 | Unable to open the database file */
//#define SQLITE_PROTOCOL    15   /* 数据库锁定协议错误 | Database lock protocol error */
//#define SQLITE_EMPTY       16   /* 数据库为空 | Database is empty */
//#define SQLITE_SCHEMA      17   /* 数据结构发生改变 | The database schema changed */
//#define SQLITE_TOOBIG      18   /* 字符串或二进制数据超过大小限制 | String or BLOB exceeds size limit */
//#define SQLITE_CONSTRAINT  19   /* 由于约束违例而取消 | Abort due to constraint violation */
//#define SQLITE_MISMATCH    20   /* 数据类型不匹配 | Data type mismatch */
//#define SQLITE_MISUSE      21   /* 不正确的库使用 | Library used incorrectly */
//#define SQLITE_NOLFS       22   /* 使用了操作系统不支持的功能 | Uses OS features not supported on host */
//#define SQLITE_AUTH        23   /* 授权失败 | Authorization denied */
//#define SQLITE_FORMAT      24   /* 附加数据库格式错误 | Auxiliary database format error */
//#define SQLITE_RANGE       25   /* 传递给sqlite3_bind()的第二个参数超出范围 | 2nd parameter to sqlite3_bind out of range */
//#define SQLITE_NOTADB      26   /* 被打开的文件不是一个数据库文件 | File opened that is not a database file */
//#define SQLITE_ROW         100  /* sqlite3_step() 已经产生一个行结果 | sqlite3_step() has another row ready */
//#define SQLITE_DONE        101  /* sqlite3_step() 完成执行操作 | sqlite3_step() has finished executing */
//    /* 错误码结束 */
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

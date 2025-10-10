package com.seven.game.cultivation.utils;

import java.util.Random;

/**
 * 修仙世界工具类
 * 提供修仙者、怪物、世界地点的名称随机生成功能
 */
public class NameUtils {
    
    private static final Random random = new Random();
    
    // 修仙者姓氏
    private static final String[] CULTIVATOR_SURNAMES = {
        "李", "王", "张", "刘", "陈", "杨", "赵", "黄", "周", "吴",
        "徐", "孙", "胡", "朱", "高", "林", "何", "郭", "马", "罗",
        "梁", "宋", "郑", "谢", "韩", "唐", "冯", "于", "董", "萧",
        "程", "曹", "袁", "邓", "许", "傅", "沈", "曾", "彭", "吕",
        "苏", "卢", "蒋", "蔡", "贾", "丁", "魏", "薛", "叶", "阎"
    };
    
    // 修仙者名字前缀
    private static final String[] CULTIVATOR_NAME_PREFIXES = {
        "天", "玄", "云", "风", "雷", "火", "水", "土", "金", "木",
        "星", "月", "日", "辰", "宇", "宙", "乾", "坤", "阴", "阳",
        "青", "白", "赤", "黑", "紫", "蓝", "绿", "黄", "银", "金",
        "龙", "凤", "虎", "麟", "鹤", "鹰", "鹏", "雀", "燕", "蝶"
    };
    
    // 修仙者名字后缀
    private static final String[] CULTIVATOR_NAME_SUFFIXES = {
        "尘", "凡", "空", "虚", "无", "有", "道", "法", "术", "诀",
        "心", "意", "神", "魂", "魄", "灵", "精", "气", "元", "丹",
        "剑", "刀", "枪", "戟", "弓", "箭", "锤", "斧", "鞭", "环",
        "山", "河", "海", "川", "林", "石", "岩", "峰", "谷", "渊"
    };
    
    // 怪物前缀
    private static final String[] MONSTER_PREFIXES = {
        "凶", "恶", "毒", "邪", "妖", "魔", "鬼", "怪", "精", "灵",
        "巨", "大", "小", "老", "幼", "金", "银", "铜", "铁", "石",
        "火", "水", "风", "雷", "冰", "土", "木", "金", "暗", "光",
        "九头", "三眼", "双尾", "独角", "多足", "飞", "爬", "游", "跳", "潜"
    };
    
    // 怪物主体
    private static final String[] MONSTER_BODIES = {
        "蛇", "龙", "虎", "豹", "狼", "熊", "狮", "象", "牛", "马",
        "鹰", "雕", "雀", "燕", "鹤", "鸡", "鸭", "鹅", "鱼", "虾",
        "蝎", "蛛", "蚁", "蜂", "蝶", "蝉", "虫", "蚯", "蚓", "蛆",
        "树", "花", "草", "藤", "蔓", "石", "岩", "土", "沙", "尘",
        "人", "仙", "佛", "神", "鬼", "魂", "魄", "尸", "骨", "血"
    };
    
    // 怪物后缀
    private static final String[] MONSTER_SUFFIXES = {
        "王", "皇", "帝", "尊", "圣", "神", "魔", "鬼", "怪", "精",
        "妖", "兽", "虫", "鸟", "鱼", "树", "花", "草", "石", "土",
        "之魂", "之灵", "之魄", "之影", "之形", "之体", "之心", "之眼", "之手", "之足",
        "长老", "首领", "头目", "将军", "元帅", "大王", "皇帝", "尊者", "圣人", "神仙"
    };
    
    // 世界地点前缀
    private static final String[] LOCATION_PREFIXES = {
        "天", "地", "玄", "黄", "宇", "宙", "洪", "荒", "日", "月",
        "星", "辰", "金", "木", "水", "火", "土", "风", "雷", "电",
        "青", "白", "赤", "黑", "紫", "蓝", "东", "西", "南", "北",
        "上", "下", "左", "右", "前", "后", "内", "外", "中", "央"
    };
    
    // 世界地点主体
    private static final String[] LOCATION_BODIES = {
        "山", "河", "海", "川", "林", "原", "谷", "峰", "岭", "丘",
        "湖", "江", "河", "溪", "泉", "瀑", "潭", "池", "井", "洞",
        "城", "镇", "村", "庄", "寨", "堡", "宫", "殿", "阁", "楼",
        "亭", "台", "塔", "庙", "寺", "观", "庵", "堂", "院", "府"
    };
    
    // 世界地点后缀
    private static final String[] LOCATION_SUFFIXES = {
        "之巅", "之渊", "之源", "之尽", "之间", "之外", "之内", "之上", "之下", "之中",
        "仙境", "魔域", "鬼界", "妖境", "神域", "佛国", "灵地", "宝地", "福地", "洞天",
        "大阵", "结界", "领域", "世界", "空间", "时空", "轮回", "因果", "命运", "天道"
    };
    
    /**
     * 生成随机修仙者名称
     * @return 修仙者名称
     */
    public static String generateCultivatorName() {
        String surname = CULTIVATOR_SURNAMES[random.nextInt(CULTIVATOR_SURNAMES.length)];
        String prefix = CULTIVATOR_NAME_PREFIXES[random.nextInt(CULTIVATOR_NAME_PREFIXES.length)];
        String suffix = CULTIVATOR_NAME_SUFFIXES[random.nextInt(CULTIVATOR_NAME_SUFFIXES.length)];
        
        // 随机决定是单字名还是双字名
        if (random.nextBoolean()) {
            return surname + prefix;
        } else {
            return surname + prefix + suffix;
        }
    }
    
    /**
     * 生成随机怪物名称
     * @return 怪物名称
     */
    public static String generateMonsterName() {
        String prefix = MONSTER_PREFIXES[random.nextInt(MONSTER_PREFIXES.length)];
        String body = MONSTER_BODIES[random.nextInt(MONSTER_BODIES.length)];
        String suffix = MONSTER_SUFFIXES[random.nextInt(MONSTER_SUFFIXES.length)];
        
        // 随机决定是否包含后缀
        if (random.nextBoolean()) {
            return prefix + body + suffix;
        } else {
            return prefix + body;
        }
    }
    
    /**
     * 生成随机世界地点名称
     * @return 世界地点名称
     */
    public static String generateLocationName() {
        String prefix = LOCATION_PREFIXES[random.nextInt(LOCATION_PREFIXES.length)];
        String body = LOCATION_BODIES[random.nextInt(LOCATION_BODIES.length)];
        String suffix = LOCATION_SUFFIXES[random.nextInt(LOCATION_SUFFIXES.length)];
        
        // 随机决定是否包含后缀
        if (random.nextBoolean()) {
            return prefix + body + suffix;
        } else {
            return prefix + body;
        }
    }
    
    /**
     * 批量生成修仙者名称
     * @param count 生成数量
     * @return 修仙者名称数组
     */
    public static String[] generateCultivatorNames(int count) {
        String[] names = new String[count];
        for (int i = 0; i < count; i++) {
            names[i] = generateCultivatorName();
        }
        return names;
    }
    
    /**
     * 批量生成怪物名称
     * @param count 生成数量
     * @return 怪物名称数组
     */
    public static String[] generateMonsterNames(int count) {
        String[] names = new String[count];
        for (int i = 0; i < count; i++) {
            names[i] = generateMonsterName();
        }
        return names;
    }
    
    /**
     * 批量生成世界地点名称
     * @param count 生成数量
     * @return 世界地点名称数组
     */
    public static String[] generateLocationNames(int count) {
        String[] names = new String[count];
        for (int i = 0; i < count; i++) {
            names[i] = generateLocationName();
        }
        return names;
    }
}
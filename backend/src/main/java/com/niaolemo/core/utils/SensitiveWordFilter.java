package com.niaolemo.core.utils;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.util.*;

/**
 * 敏感词过滤器
 * 使用DFA算法实现高效的敏感词检测
 * 
 * @author niaolemo-team
 */
@Slf4j
@Component
public class SensitiveWordFilter {

    /**
     * 敏感词库 - 政治敏感词汇
     */
    private static final Set<String> SENSITIVE_WORDS = new HashSet<>(Arrays.asList(
        // 政治相关
        "习近平", "毛泽东", "邓小平", "江泽民", "胡锦涛", "温家宝", "李克强", "李鹏", "朱镕基",
        "共产党", "国民党", "民进党", "法轮功", "达赖", "台独", "藏独", "疆独", "港独",
        "六四", "天安门", "文革", "大跃进", "反右", "镇压", "民运", "异议", "维权",
        "民主", "自由", "人权", "专制", "独裁", "暴政", "革命", "起义", "造反",
        
        // 宗教极端
        "真主", "圣战", "伊斯兰国", "基地组织", "塔利班", "恐怖主义", "极端主义",
        
        // 违法犯罪
        "毒品", "海洛因", "冰毒", "摇头丸", "大麻", "可卡因", "吸毒", "贩毒",
        "枪支", "手枪", "步枪", "炸药", "炸弹", "爆炸", "暗杀", "杀手",
        "赌博", "博彩", "六合彩", "时时彩", "赌场", "老虎机", "百家乐",
        "诈骗", "传销", "洗钱", "走私", "偷税", "漏税", "贪污", "受贿",
        
        // 色情低俗
        "色情", "黄色", "成人", "情色", "性爱", "做爱", "性交", "强奸",
        "妓女", "嫖娼", "卖淫", "援交", "包养", "小三", "出轨", "偷情",
        
        // 暴力血腥
        "杀人", "谋杀", "自杀", "死亡", "尸体", "血腥", "暴力", "虐待",
        "砍头", "斩首", "酷刑", "折磨", "残忍", "血淋淋",
        
        // 歧视仇恨
        "种族歧视", "性别歧视", "地域歧视", "仇恨", "辱骂", "诅咒",
        "支那", "小日本", "棒子", "阿三", "黑鬼", "白皮猪",
        
        // 其他敏感
        "病毒", "瘟疫", "传染病", "疫情", "封城", "隔离",
        "股市", "崩盘", "经济危机", "金融危机", "通胀", "通缩"
    ));

    /**
     * DFA状态机
     */
    private final Map<Character, Object> dfaMap;

    public SensitiveWordFilter() {
        this.dfaMap = buildDFAMap();
    }

    /**
     * 构建DFA状态机
     */
    private Map<Character, Object> buildDFAMap() {
        Map<Character, Object> dfaMap = new HashMap<>();
        
        for (String word : SENSITIVE_WORDS) {
            if (word == null || word.trim().isEmpty()) {
                continue;
            }
            
            Map<Character, Object> currentMap = dfaMap;
            char[] chars = word.toCharArray();
            
            for (int i = 0; i < chars.length; i++) {
                char c = chars[i];
                Object obj = currentMap.get(c);
                
                if (obj == null) {
                    Map<Character, Object> newMap = new HashMap<>();
                    currentMap.put(c, newMap);
                    currentMap = newMap;
                } else {
                    currentMap = (Map<Character, Object>) obj;
                }
                
                // 最后一个字符，标记为结束
                if (i == chars.length - 1) {
                    currentMap.put('*', true);
                }
            }
        }
        
        log.info("敏感词库初始化完成，共加载 {} 个敏感词", SENSITIVE_WORDS.size());
        return dfaMap;
    }

    /**
     * 检查文本是否包含敏感词
     */
    public boolean containsSensitiveWord(String text) {
        if (text == null || text.trim().isEmpty()) {
            return false;
        }
        
        // 转换为小写并去除空格
        String cleanText = text.toLowerCase().replaceAll("\\s+", "");
        char[] chars = cleanText.toCharArray();
        
        for (int i = 0; i < chars.length; i++) {
            int length = checkSensitiveWord(chars, i);
            if (length > 0) {
                return true;
            }
        }
        
        return false;
    }

    /**
     * 获取文本中的敏感词列表
     */
    public List<String> getSensitiveWords(String text) {
        List<String> sensitiveWords = new ArrayList<>();
        
        if (text == null || text.trim().isEmpty()) {
            return sensitiveWords;
        }
        
        String cleanText = text.toLowerCase().replaceAll("\\s+", "");
        char[] chars = cleanText.toCharArray();
        
        for (int i = 0; i < chars.length; i++) {
            int length = checkSensitiveWord(chars, i);
            if (length > 0) {
                String word = new String(chars, i, length);
                sensitiveWords.add(word);
                i += length - 1; // 跳过已检测的字符
            }
        }
        
        return sensitiveWords;
    }

    /**
     * 替换敏感词
     */
    public String replaceSensitiveWords(String text, String replacement) {
        if (text == null || text.trim().isEmpty()) {
            return text;
        }
        
        StringBuilder result = new StringBuilder();
        String cleanText = text.toLowerCase().replaceAll("\\s+", "");
        char[] chars = cleanText.toCharArray();
        
        for (int i = 0; i < chars.length; i++) {
            int length = checkSensitiveWord(chars, i);
            if (length > 0) {
                result.append(replacement);
                i += length - 1;
            } else {
                result.append(chars[i]);
            }
        }
        
        return result.toString();
    }

    /**
     * 检查从指定位置开始的敏感词长度
     */
    private int checkSensitiveWord(char[] chars, int startIndex) {
        Map<Character, Object> currentMap = dfaMap;
        int wordLength = 0;
        boolean isEnd = false;
        
        for (int i = startIndex; i < chars.length; i++) {
            char c = chars[i];
            Object obj = currentMap.get(c);
            
            if (obj == null) {
                break;
            }
            
            wordLength++;
            currentMap = (Map<Character, Object>) obj;
            
            // 检查是否到达敏感词结尾
            if (currentMap.containsKey('*')) {
                isEnd = true;
            }
        }
        
        return isEnd ? wordLength : 0;
    }

    /**
     * 添加敏感词
     */
    public void addSensitiveWord(String word) {
        if (word == null || word.trim().isEmpty()) {
            return;
        }
        
        SENSITIVE_WORDS.add(word.toLowerCase());
        // 重新构建DFA状态机
        Map<Character, Object> newDfaMap = buildDFAMap();
        dfaMap.clear();
        dfaMap.putAll(newDfaMap);
        
        log.info("添加敏感词: {}", word);
    }

    /**
     * 批量添加敏感词
     */
    public void addSensitiveWords(Collection<String> words) {
        if (words == null || words.isEmpty()) {
            return;
        }
        
        for (String word : words) {
            if (word != null && !word.trim().isEmpty()) {
                SENSITIVE_WORDS.add(word.toLowerCase());
            }
        }
        
        // 重新构建DFA状态机
        Map<Character, Object> newDfaMap = buildDFAMap();
        dfaMap.clear();
        dfaMap.putAll(newDfaMap);
        
        log.info("批量添加敏感词: {} 个", words.size());
    }

    /**
     * 获取敏感词库大小
     */
    public int getSensitiveWordCount() {
        return SENSITIVE_WORDS.size();
    }
}
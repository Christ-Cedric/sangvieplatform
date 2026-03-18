import React, { useState, useEffect, useRef } from "react";
import { HospitalLayout, DonorLayout } from "../../components/layouts";
import { useAuth } from "../../AuthContext";
import { 
  getConversationsApi, 
  getMessagesApi, 
  sendMessageApi, 
  Conversation, 
  Message 
} from "../../api";
import { MessageSquare, Send, Loader2, Building2, User, ArrowLeft } from "lucide-react";
import { useTranslation } from "../../i18n";

export function Messages() {
  const { user } = useAuth();
  const { t } = useTranslation();
  const [conversations, setConversations] = useState<Conversation[]>([]);
  const [selectedConv, setSelectedConv] = useState<Conversation | null>(null);
  const [messages, setMessages] = useState<Message[]>([]);
  const [isLoadingConvs, setIsLoadingConvs] = useState(true);
  const [isLoadingMsgs, setIsLoadingMsgs] = useState(false);
  const [content, setContent] = useState("");
  const scrollRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    fetchConversations();
  }, []);

  useEffect(() => {
    if (selectedConv) {
      fetchMessages(selectedConv.otherId);
    }
  }, [selectedConv]);

  useEffect(() => {
    if (scrollRef.current) {
      scrollRef.current.scrollTop = scrollRef.current.scrollHeight;
    }
  }, [messages]);

  const fetchConversations = async () => {
    try {
      const data = await getConversationsApi();
      setConversations(data);
    } catch (err) {
      console.error(err);
    } finally {
      setIsLoadingConvs(false);
    }
  };

  const fetchMessages = async (otherId: string) => {
    setIsLoadingMsgs(true);
    try {
      const data = await getMessagesApi(otherId);
      setMessages(data);
    } catch (err) {
      console.error(err);
    } finally {
      setIsLoadingMsgs(false);
    }
  };

  const handleSend = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!content.trim() || !selectedConv) return;

    try {
      const newMsg = await sendMessageApi({
        receiverId: selectedConv.otherId,
        receiverType: selectedConv.otherType,
        content: content.trim()
      });
      setMessages([...messages, newMsg]);
      setContent("");
      fetchConversations(); // Update last message in sidebar
    } catch (err) {
      console.error(err);
    }
  };

  const handleBackToList = () => {
    setSelectedConv(null);
  };

  const Layout = user?.role === 'hospital' ? HospitalLayout : DonorLayout;

  return (
    <Layout>
      <div className="flex h-[calc(100vh-160px)] md:h-[calc(100vh-100px)] lg:h-[calc(100vh-60px)] bg-white rounded-3xl border border-[#F0F0F0] overflow-hidden shadow-sm mt-4 md:mt-6 mx-4 md:mx-6 lg:mx-8 mb-4">
        
        {/* Sidebar */}
        <div className={`w-full md:w-80 border-r border-[#F0F0F0] flex flex-col bg-[#FBFBFB] transition-transform duration-300 ${selectedConv ? 'hidden md:flex' : 'flex'}`}>
          <div className="p-4 md:p-6 border-b border-[#F0F0F0]">
            <h2 className="text-xl font-bold flex items-center gap-2 font-['DM_Sans']">
              <MessageSquare className="w-5 h-5 text-[#CC0000]" />
              {t("messages.title")}
            </h2>
          </div>
          <div className="flex-1 overflow-y-auto">
            {isLoadingConvs ? (
              <div className="flex justify-center p-8"><Loader2 className="animate-spin text-[#CC0000]" /></div>
            ) : conversations.length === 0 ? (
              <div className="p-8 text-center text-[#AAAAAA] text-sm">{t("messages.empty")}</div>
            ) : (
              conversations.map((c) => (
                <div 
                  key={c.otherId}
                  onClick={() => setSelectedConv(c)}
                  className={`p-4 cursor-pointer hover:bg-[#F5F5F5] transition-colors border-b border-[#F0F0F0] ${selectedConv?.otherId === c.otherId ? 'bg-white font-bold border-l-4 border-l-[#CC0000]' : 'border-l-4 border-l-transparent'}`}
                >
                  <div className="flex items-center gap-3">
                    <div className="w-10 h-10 rounded-full bg-[#CC0000]/10 flex items-center justify-center text-[#CC0000] flex-shrink-0 font-bold text-xs">
                      {(c.otherName || 'Unknown').split(' ').map(n => n[0]).join('').slice(0, 2).toUpperCase()}
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className="text-sm truncate font-['DM_Sans'] text-[#111111]">{c.otherName || (c.otherType === 'Hospital' ? t("messages.hospital_default") : t("messages.donor_default"))}</p>
                      <p className={`text-xs truncate font-['DM_Sans'] ${c.isRead ? 'text-[#888888] font-normal' : 'text-[#CC0000] font-bold'}`}>
                        {c.lastMessage}
                      </p>
                    </div>
                    {!c.isRead && (
                       <div className="w-2.5 h-2.5 rounded-full bg-[#CC0000] flex-shrink-0" />
                    )}
                  </div>
                </div>
              ))
            )}
          </div>
        </div>

        {/* Chat Area */}
        <div className={`flex-1 flex col flex-col bg-white ${!selectedConv ? 'hidden md:flex' : 'flex'}`}>
          {selectedConv ? (
            <>
              {/* Chat Header */}
              <div className="p-4 border-b border-[#F0F0F0] bg-[#FBFBFB] flex items-center gap-3 relative shadow-sm z-10">
                <button 
                  onClick={handleBackToList}
                  className="md:hidden p-2 -ml-2 rounded-full hover:bg-[#EBEBEB] text-[#555555] transition-colors"
                >
                  <ArrowLeft className="w-5 h-5" />
                </button>
                <div className="w-9 h-9 rounded-full bg-[#CC0000]/10 flex items-center justify-center text-[#CC0000] font-bold text-xs">
                  {(selectedConv.otherName || 'Unknown').split(' ').map(n => n[0]).join('').slice(0, 2).toUpperCase()}
                </div>
                <div className="flex flex-col">
                  <h3 className="font-bold text-[15px] font-['DM_Sans'] text-[#111111] leading-tight">
                    {selectedConv.otherName || (selectedConv.otherType === 'Hospital' ? t("messages.hospital_default") : t("messages.donor_default"))}
                  </h3>
                  <span className="text-[11px] text-[#1A7A3F] font-semibold flex items-center gap-1 mt-0.5">
                    <span className="w-1.5 h-1.5 rounded-full bg-[#1A7A3F] inline-block" />
                    {t("messages.online")}
                  </span>
                </div>
              </div>

              {/* Chat Messages */}
              <div ref={scrollRef} className="flex-1 overflow-y-auto p-4 md:p-6 space-y-5 bg-[#F9F9F9]/50">
                {isLoadingMsgs ? (
                  <div className="flex justify-center flex-1 items-center h-full"><Loader2 className="animate-spin text-[#CC0000] w-8 h-8" /></div>
                ) : (
                  messages.map((m) => (
                    <div key={m._id} className={`flex ${m.senderId === user?._id ? 'justify-end' : 'justify-start'}`}>
                      <div className={`max-w-[85%] md:max-w-[70%] px-4 py-2.5 rounded-[20px] text-[14px] shadow-sm font-['DM_Sans'] flex flex-col ${m.senderId === user?._id ? 'bg-gradient-to-br from-[#CC0000] to-[#E60000] text-white rounded-br-sm' : 'bg-white text-[#111111] border border-[#EBEBEB] rounded-bl-sm'}`}>
                        <span className="leading-relaxed">{m.content}</span>
                        <span className={`text-[10px] mt-1 text-right font-medium ${m.senderId === user?._id ? 'text-white/80' : 'text-[#888888]'}`}>
                          {new Date(m.createdAt).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                        </span>
                      </div>
                    </div>
                  ))
                )}
              </div>

              {/* Chat Input */}
              <div className="p-3 md:p-4 border-t border-[#F0F0F0] bg-white">
                <form onSubmit={handleSend} className="flex gap-2 items-center bg-[#F9F9F9] border border-[#EBEBEB] p-1.5 rounded-2xl focus-within:border-[#CC0000]/30 focus-within:ring-4 focus-within:ring-[#CC0000]/10 transition-all">
                  <input 
                    type="text" 
                    value={content}
                    onChange={(e) => setContent(e.target.value)}
                    placeholder={t("messages.placeholder")} 
                    className="flex-1 bg-transparent border-none px-4 py-2.5 text-sm outline-none font-['DM_Sans'] text-[#111111] placeholder:text-[#AAAAAA]"
                  />
                  <button 
                    type="submit" 
                    disabled={!content.trim()}
                    className={`p-3 rounded-xl transition-all flex items-center justify-center ${content.trim() ? 'bg-[#CC0000] text-white hover:bg-[#AA0000] hover:scale-105 shadow-md shadow-[#CC0000]/20' : 'bg-[#EBEBEB] text-[#AAAAAA] cursor-not-allowed'}`}
                  >
                    <Send className="w-5 h-5 ml-1" />
                  </button>
                </form>
              </div>
            </>
          ) : (
            <div className="flex-1 flex flex-col items-center justify-center p-12 text-center text-[#AAAAAA]">
              <div className="w-20 h-20 rounded-full bg-[#F5F5F5] flex items-center justify-center mb-5">
                <MessageSquare className="w-10 h-10 text-[#CCCCCC]" />
              </div>
              <h3 className="text-xl font-bold text-[#333333] mb-2 font-['DM_Sans']">{t("messages.welcome.title")}</h3>
              <p className="text-[14px] max-w-sm">{t("messages.welcome.sub")}</p>
            </div>
          )}
        </div>
      </div>
    </Layout>
  );
}

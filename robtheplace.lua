--[[
 .____                  ________ ___.    _____                           __                
 |    |    __ _______   \_____  \\_ |___/ ____\_ __  ______ ____ _____ _/  |_  ___________ 
 |    |   |  |  \__  \   /   |   \| __ \   __\  |  \/  ___// ___\\__  \\   __\/  _ \_  __ \
 |    |___|  |  // __ \_/    |    \ \_\ \  | |  |  /\___ \\  \___ / __ \|  | (  <_> )  | \/
 |_______ \____/(____  /\_______  /___  /__| |____//____  >\___  >____  /__|  \____/|__|   
         \/          \/         \/    \/                \/     \/     \/                   
          \_Welcome to LuaObfuscator.com   (Alpha 0.10.6) ~  Much Love, Ferib 

]]--

local StrToNumber = tonumber;
local Byte = string.byte;
local Char = string.char;
local Sub = string.sub;
local Subg = string.gsub;
local Rep = string.rep;
local Concat = table.concat;
local Insert = table.insert;
local LDExp = math.ldexp;
local GetFEnv = getfenv or function()
	return _ENV;
end;
local Setmetatable = setmetatable;
local PCall = pcall;
local Select = select;
local Unpack = unpack or table.unpack;
local ToNumber = tonumber;
local function VMCall(ByteString, vmenv, ...)
	local DIP = 1;
	local repeatNext;
	ByteString = Subg(Sub(ByteString, 5), "..", function(byte)
		if (Byte(byte, 2) == 79) then
			local FlatIdent_76979 = 0;
			while true do
				if (FlatIdent_76979 == 0) then
					repeatNext = StrToNumber(Sub(byte, 1, 1));
					return "";
				end
			end
		else
			local a = Char(StrToNumber(byte, 16));
			if repeatNext then
				local b = Rep(a, repeatNext);
				repeatNext = nil;
				return b;
			else
				return a;
			end
		end
	end);
	local function gBit(Bit, Start, End)
		if End then
			local Res = (Bit / (2 ^ (Start - 1))) % (2 ^ (((End - 1) - (Start - 1)) + 1));
			return Res - (Res % 1);
		else
			local Plc = 2 ^ (Start - 1);
			return (((Bit % (Plc + Plc)) >= Plc) and 1) or 0;
		end
	end
	local function gBits8()
		local a = Byte(ByteString, DIP, DIP);
		DIP = DIP + 1;
		return a;
	end
	local function gBits16()
		local a, b = Byte(ByteString, DIP, DIP + 2);
		DIP = DIP + 2;
		return (b * 256) + a;
	end
	local function gBits32()
		local a, b, c, d = Byte(ByteString, DIP, DIP + 3);
		DIP = DIP + 4;
		return (d * 16777216) + (c * 65536) + (b * 256) + a;
	end
	local function gFloat()
		local FlatIdent_69270 = 0;
		local Left;
		local Right;
		local IsNormal;
		local Mantissa;
		local Exponent;
		local Sign;
		while true do
			if (FlatIdent_69270 == 3) then
				if (Exponent == 0) then
					if (Mantissa == 0) then
						return Sign * 0;
					else
						Exponent = 1;
						IsNormal = 0;
					end
				elseif (Exponent == 2047) then
					return ((Mantissa == 0) and (Sign * (1 / 0))) or (Sign * NaN);
				end
				return LDExp(Sign, Exponent - 1023) * (IsNormal + (Mantissa / (2 ^ 52)));
			end
			if (FlatIdent_69270 == 0) then
				Left = gBits32();
				Right = gBits32();
				FlatIdent_69270 = 1;
			end
			if (FlatIdent_69270 == 2) then
				Exponent = gBit(Right, 21, 31);
				Sign = ((gBit(Right, 32) == 1) and -1) or 1;
				FlatIdent_69270 = 3;
			end
			if (FlatIdent_69270 == 1) then
				IsNormal = 1;
				Mantissa = (gBit(Right, 1, 20) * (2 ^ 32)) + Left;
				FlatIdent_69270 = 2;
			end
		end
	end
	local function gString(Len)
		local Str;
		if not Len then
			Len = gBits32();
			if (Len == 0) then
				return "";
			end
		end
		Str = Sub(ByteString, DIP, (DIP + Len) - 1);
		DIP = DIP + Len;
		local FStr = {};
		for Idx = 1, #Str do
			FStr[Idx] = Char(Byte(Sub(Str, Idx, Idx)));
		end
		return Concat(FStr);
	end
	local gInt = gBits32;
	local function _R(...)
		return {...}, Select("#", ...);
	end
	local function Deserialize()
		local Instrs = {};
		local Functions = {};
		local Lines = {};
		local Chunk = {Instrs,Functions,nil,Lines};
		local ConstCount = gBits32();
		local Consts = {};
		for Idx = 1, ConstCount do
			local FlatIdent_8D83D = 0;
			local Type;
			local Cons;
			while true do
				if (FlatIdent_8D83D == 1) then
					if (Type == 1) then
						Cons = gBits8() ~= 0;
					elseif (Type == 2) then
						Cons = gFloat();
					elseif (Type == 3) then
						Cons = gString();
					end
					Consts[Idx] = Cons;
					break;
				end
				if (FlatIdent_8D83D == 0) then
					Type = gBits8();
					Cons = nil;
					FlatIdent_8D83D = 1;
				end
			end
		end
		Chunk[3] = gBits8();
		for Idx = 1, gBits32() do
			local FlatIdent_44839 = 0;
			local Descriptor;
			while true do
				if (FlatIdent_44839 == 0) then
					Descriptor = gBits8();
					if (gBit(Descriptor, 1, 1) == 0) then
						local FlatIdent_25011 = 0;
						local Type;
						local Mask;
						local Inst;
						while true do
							if (FlatIdent_25011 == 2) then
								if (gBit(Mask, 1, 1) == 1) then
									Inst[2] = Consts[Inst[2]];
								end
								if (gBit(Mask, 2, 2) == 1) then
									Inst[3] = Consts[Inst[3]];
								end
								FlatIdent_25011 = 3;
							end
							if (FlatIdent_25011 == 0) then
								Type = gBit(Descriptor, 2, 3);
								Mask = gBit(Descriptor, 4, 6);
								FlatIdent_25011 = 1;
							end
							if (FlatIdent_25011 == 3) then
								if (gBit(Mask, 3, 3) == 1) then
									Inst[4] = Consts[Inst[4]];
								end
								Instrs[Idx] = Inst;
								break;
							end
							if (FlatIdent_25011 == 1) then
								Inst = {gBits16(),gBits16(),nil,nil};
								if (Type == 0) then
									Inst[3] = gBits16();
									Inst[4] = gBits16();
								elseif (Type == 1) then
									Inst[3] = gBits32();
								elseif (Type == 2) then
									Inst[3] = gBits32() - (2 ^ 16);
								elseif (Type == 3) then
									local FlatIdent_51F42 = 0;
									while true do
										if (FlatIdent_51F42 == 0) then
											Inst[3] = gBits32() - (2 ^ 16);
											Inst[4] = gBits16();
											break;
										end
									end
								end
								FlatIdent_25011 = 2;
							end
						end
					end
					break;
				end
			end
		end
		for Idx = 1, gBits32() do
			Functions[Idx - 1] = Deserialize();
		end
		return Chunk;
	end
	local function Wrap(Chunk, Upvalues, Env)
		local Instr = Chunk[1];
		local Proto = Chunk[2];
		local Params = Chunk[3];
		return function(...)
			local Instr = Instr;
			local Proto = Proto;
			local Params = Params;
			local _R = _R;
			local VIP = 1;
			local Top = -1;
			local Vararg = {};
			local Args = {...};
			local PCount = Select("#", ...) - 1;
			local Lupvals = {};
			local Stk = {};
			for Idx = 0, PCount do
				if (Idx >= Params) then
					Vararg[Idx - Params] = Args[Idx + 1];
				else
					Stk[Idx] = Args[Idx + 1];
				end
			end
			local Varargsz = (PCount - Params) + 1;
			local Inst;
			local Enum;
			while true do
				Inst = Instr[VIP];
				Enum = Inst[1];
				if (Enum <= 53) then
					if (Enum <= 26) then
						if (Enum <= 12) then
							if (Enum <= 5) then
								if (Enum <= 2) then
									if (Enum <= 0) then
										local FlatIdent_7FAC9 = 0;
										local A;
										while true do
											if (FlatIdent_7FAC9 == 5) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												FlatIdent_7FAC9 = 6;
											end
											if (FlatIdent_7FAC9 == 2) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_7FAC9 = 3;
											end
											if (FlatIdent_7FAC9 == 3) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_7FAC9 = 4;
											end
											if (FlatIdent_7FAC9 == 0) then
												A = nil;
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_7FAC9 = 1;
											end
											if (FlatIdent_7FAC9 == 7) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												break;
											end
											if (FlatIdent_7FAC9 == 6) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												FlatIdent_7FAC9 = 7;
											end
											if (FlatIdent_7FAC9 == 4) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												FlatIdent_7FAC9 = 5;
											end
											if (1 == FlatIdent_7FAC9) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_7FAC9 = 2;
											end
										end
									elseif (Enum > 1) then
										local FlatIdent_12544 = 0;
										local Edx;
										local Results;
										local Limit;
										local B;
										local A;
										while true do
											if (FlatIdent_12544 == 8) then
												Inst = Instr[VIP];
												if Stk[Inst[2]] then
													VIP = VIP + 1;
												else
													VIP = Inst[3];
												end
												break;
											end
											if (FlatIdent_12544 == 6) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
												FlatIdent_12544 = 7;
											end
											if (FlatIdent_12544 == 3) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_12544 = 4;
											end
											if (FlatIdent_12544 == 1) then
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												FlatIdent_12544 = 2;
											end
											if (7 == FlatIdent_12544) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_12544 = 8;
											end
											if (FlatIdent_12544 == 0) then
												Edx = nil;
												Results, Limit = nil;
												B = nil;
												A = nil;
												FlatIdent_12544 = 1;
											end
											if (5 == FlatIdent_12544) then
												Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
												Top = (Limit + A) - 1;
												Edx = 0;
												for Idx = A, Top do
													local FlatIdent_4CC24 = 0;
													while true do
														if (FlatIdent_4CC24 == 0) then
															Edx = Edx + 1;
															Stk[Idx] = Results[Edx];
															break;
														end
													end
												end
												FlatIdent_12544 = 6;
											end
											if (FlatIdent_12544 == 4) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_12544 = 5;
											end
											if (FlatIdent_12544 == 2) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_12544 = 3;
											end
										end
									else
										local A;
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									end
								elseif (Enum <= 3) then
									local A = Inst[2];
									Stk[A] = Stk[A]();
								elseif (Enum == 4) then
									local Edx;
									local Results, Limit;
									local B;
									local A;
									Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
									Top = (Limit + A) - 1;
									Edx = 0;
									for Idx = A, Top do
										local FlatIdent_207CC = 0;
										while true do
											if (FlatIdent_207CC == 0) then
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
												break;
											end
										end
									end
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = {};
								else
									Upvalues[Inst[3]] = Stk[Inst[2]];
								end
							elseif (Enum <= 8) then
								if (Enum <= 6) then
									local A;
									Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Stk[Inst[3]]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								elseif (Enum > 7) then
									local Edx;
									local Results, Limit;
									local A;
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
									Top = (Limit + A) - 1;
									Edx = 0;
									for Idx = A, Top do
										Edx = Edx + 1;
										Stk[Idx] = Results[Edx];
									end
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									VIP = Inst[3];
								else
									local A = Inst[2];
									Stk[A] = Stk[A](Stk[A + 1]);
								end
							elseif (Enum <= 10) then
								if (Enum == 9) then
									Stk[Inst[2]] = Upvalues[Inst[3]];
								else
									Stk[Inst[2]] = Inst[3] ~= 0;
								end
							elseif (Enum > 11) then
								local B;
								local A;
								Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = {};
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
							else
								local NewProto = Proto[Inst[3]];
								local NewUvals;
								local Indexes = {};
								NewUvals = Setmetatable({}, {__index=function(_, Key)
									local Val = Indexes[Key];
									return Val[1][Val[2]];
								end,__newindex=function(_, Key, Value)
									local Val = Indexes[Key];
									Val[1][Val[2]] = Value;
								end});
								for Idx = 1, Inst[4] do
									VIP = VIP + 1;
									local Mvm = Instr[VIP];
									if (Mvm[1] == 61) then
										Indexes[Idx - 1] = {Stk,Mvm[3]};
									else
										Indexes[Idx - 1] = {Upvalues,Mvm[3]};
									end
									Lupvals[#Lupvals + 1] = Indexes;
								end
								Stk[Inst[2]] = Wrap(NewProto, NewUvals, Env);
							end
						elseif (Enum <= 19) then
							if (Enum <= 15) then
								if (Enum <= 13) then
									local T;
									local Edx;
									local Results, Limit;
									local A;
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
									Top = (Limit + A) - 1;
									Edx = 0;
									for Idx = A, Top do
										Edx = Edx + 1;
										Stk[Idx] = Results[Edx];
									end
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									T = Stk[A];
									for Idx = A + 1, Top do
										Insert(T, Stk[Idx]);
									end
								elseif (Enum == 14) then
									local FlatIdent_6DC53 = 0;
									local Edx;
									local Results;
									local B;
									local A;
									while true do
										if (FlatIdent_6DC53 == 6) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_6DC53 = 7;
										end
										if (FlatIdent_6DC53 == 9) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											VIP = Inst[3];
											break;
										end
										if (FlatIdent_6DC53 == 4) then
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_6DC53 = 5;
										end
										if (FlatIdent_6DC53 == 1) then
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											FlatIdent_6DC53 = 2;
										end
										if (FlatIdent_6DC53 == 8) then
											A = Inst[2];
											Results = {Stk[A](Stk[A + 1])};
											Edx = 0;
											for Idx = A, Inst[4] do
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
											end
											FlatIdent_6DC53 = 9;
										end
										if (5 == FlatIdent_6DC53) then
											Stk[A] = Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											FlatIdent_6DC53 = 6;
										end
										if (FlatIdent_6DC53 == 7) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_6DC53 = 8;
										end
										if (FlatIdent_6DC53 == 3) then
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											FlatIdent_6DC53 = 4;
										end
										if (FlatIdent_6DC53 == 2) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											FlatIdent_6DC53 = 3;
										end
										if (0 == FlatIdent_6DC53) then
											Edx = nil;
											Results = nil;
											B = nil;
											A = nil;
											FlatIdent_6DC53 = 1;
										end
									end
								else
									local A = Inst[2];
									local T = Stk[A];
									for Idx = A + 1, Inst[3] do
										Insert(T, Stk[Idx]);
									end
								end
							elseif (Enum <= 17) then
								if (Enum == 16) then
									local FlatIdent_45D37 = 0;
									local A;
									while true do
										if (FlatIdent_45D37 == 1) then
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Inst[4];
											FlatIdent_45D37 = 2;
										end
										if (FlatIdent_45D37 == 5) then
											Stk[Inst[2]] = Inst[3];
											break;
										end
										if (FlatIdent_45D37 == 0) then
											A = nil;
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_45D37 = 1;
										end
										if (FlatIdent_45D37 == 2) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_45D37 = 3;
										end
										if (FlatIdent_45D37 == 3) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_45D37 = 4;
										end
										if (FlatIdent_45D37 == 4) then
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_45D37 = 5;
										end
									end
								elseif not Stk[Inst[2]] then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							elseif (Enum == 18) then
								local FlatIdent_32B97 = 0;
								local A;
								while true do
									if (FlatIdent_32B97 == 0) then
										A = Inst[2];
										Stk[A](Unpack(Stk, A + 1, Top));
										break;
									end
								end
							else
								local FlatIdent_1FC27 = 0;
								local B;
								local A;
								while true do
									if (FlatIdent_1FC27 == 4) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_1FC27 = 5;
									end
									if (FlatIdent_1FC27 == 0) then
										B = nil;
										A = nil;
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										FlatIdent_1FC27 = 1;
									end
									if (FlatIdent_1FC27 == 1) then
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_1FC27 = 2;
									end
									if (FlatIdent_1FC27 == 3) then
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										FlatIdent_1FC27 = 4;
									end
									if (FlatIdent_1FC27 == 2) then
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										FlatIdent_1FC27 = 3;
									end
									if (FlatIdent_1FC27 == 5) then
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										break;
									end
								end
							end
						elseif (Enum <= 22) then
							if (Enum <= 20) then
								Stk[Inst[2]][Inst[3]] = Inst[4];
							elseif (Enum > 21) then
								local Edx;
								local Results, Limit;
								local A;
								Stk[Inst[2]] = Upvalues[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
								Top = (Limit + A) - 1;
								Edx = 0;
								for Idx = A, Top do
									local FlatIdent_521D6 = 0;
									while true do
										if (0 == FlatIdent_521D6) then
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
											break;
										end
									end
								end
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								if Stk[Inst[2]] then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							else
								local B;
								local A;
								Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = {};
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
							end
						elseif (Enum <= 24) then
							if (Enum == 23) then
								local Edx;
								local Results, Limit;
								local A;
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Upvalues[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Upvalues[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Upvalues[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Upvalues[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]] + Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
								Top = (Limit + A) - 1;
								Edx = 0;
								for Idx = A, Top do
									Edx = Edx + 1;
									Stk[Idx] = Results[Edx];
								end
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Upvalues[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Upvalues[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = #Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]] % Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3] + Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = #Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]] % Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3] + Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]] + Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
								Top = (Limit + A) - 1;
								Edx = 0;
								for Idx = A, Top do
									local FlatIdent_634AF = 0;
									while true do
										if (0 == FlatIdent_634AF) then
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
											break;
										end
									end
								end
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Top)));
								Top = (Limit + A) - 1;
								Edx = 0;
								for Idx = A, Top do
									local FlatIdent_4223E = 0;
									while true do
										if (FlatIdent_4223E == 0) then
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
											break;
										end
									end
								end
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]] % Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Results, Limit = _R(Stk[A](Stk[A + 1]));
								Top = (Limit + A) - 1;
								Edx = 0;
								for Idx = A, Top do
									Edx = Edx + 1;
									Stk[Idx] = Results[Edx];
								end
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A](Unpack(Stk, A + 1, Top));
							else
								local FlatIdent_6AEED = 0;
								local A;
								local Step;
								local Index;
								while true do
									if (FlatIdent_6AEED == 2) then
										if (Step > 0) then
											if (Index <= Stk[A + 1]) then
												VIP = Inst[3];
												Stk[A + 3] = Index;
											end
										elseif (Index >= Stk[A + 1]) then
											local FlatIdent_331F0 = 0;
											while true do
												if (FlatIdent_331F0 == 0) then
													VIP = Inst[3];
													Stk[A + 3] = Index;
													break;
												end
											end
										end
										break;
									end
									if (FlatIdent_6AEED == 0) then
										A = Inst[2];
										Step = Stk[A + 2];
										FlatIdent_6AEED = 1;
									end
									if (FlatIdent_6AEED == 1) then
										Index = Stk[A] + Step;
										Stk[A] = Index;
										FlatIdent_6AEED = 2;
									end
								end
							end
						elseif (Enum == 25) then
							do
								return;
							end
						else
							local A;
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
						end
					elseif (Enum <= 39) then
						if (Enum <= 32) then
							if (Enum <= 29) then
								if (Enum <= 27) then
									local FlatIdent_53124 = 0;
									local Edx;
									local Results;
									local Limit;
									local A;
									while true do
										if (FlatIdent_53124 == 0) then
											Edx = nil;
											Results, Limit = nil;
											A = nil;
											Stk[Inst[2]] = Upvalues[Inst[3]];
											FlatIdent_53124 = 1;
										end
										if (FlatIdent_53124 == 2) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_53124 = 3;
										end
										if (FlatIdent_53124 == 1) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_53124 = 2;
										end
										if (FlatIdent_53124 == 5) then
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											if Stk[Inst[2]] then
												VIP = VIP + 1;
											else
												VIP = Inst[3];
											end
											break;
										end
										if (4 == FlatIdent_53124) then
											for Idx = A, Top do
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
											end
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_53124 = 5;
										end
										if (3 == FlatIdent_53124) then
											A = Inst[2];
											Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
											Top = (Limit + A) - 1;
											Edx = 0;
											FlatIdent_53124 = 4;
										end
									end
								elseif (Enum > 28) then
									local FlatIdent_8638E = 0;
									local Edx;
									local Results;
									local B;
									local A;
									while true do
										if (FlatIdent_8638E == 4) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											FlatIdent_8638E = 5;
										end
										if (FlatIdent_8638E == 7) then
											Results = {Stk[A](Stk[A + 1])};
											Edx = 0;
											for Idx = A, Inst[4] do
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
											end
											FlatIdent_8638E = 8;
										end
										if (FlatIdent_8638E == 2) then
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											FlatIdent_8638E = 3;
										end
										if (FlatIdent_8638E == 5) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											FlatIdent_8638E = 6;
										end
										if (6 == FlatIdent_8638E) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_8638E = 7;
										end
										if (FlatIdent_8638E == 8) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											VIP = Inst[3];
											break;
										end
										if (FlatIdent_8638E == 0) then
											Edx = nil;
											Results = nil;
											B = nil;
											FlatIdent_8638E = 1;
										end
										if (FlatIdent_8638E == 1) then
											A = nil;
											A = Inst[2];
											B = Stk[Inst[3]];
											FlatIdent_8638E = 2;
										end
										if (FlatIdent_8638E == 3) then
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A](Stk[A + 1]);
											FlatIdent_8638E = 4;
										end
									end
								else
									Stk[Inst[2]] = Stk[Inst[3]] % Stk[Inst[4]];
								end
							elseif (Enum <= 30) then
								Stk[Inst[2]] = Wrap(Proto[Inst[3]], nil, Env);
							elseif (Enum > 31) then
								local A;
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								VIP = Inst[3];
							else
								Stk[Inst[2]] = Inst[3];
							end
						elseif (Enum <= 35) then
							if (Enum <= 33) then
								local A;
								Stk[Inst[2]] = {};
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
							elseif (Enum == 34) then
								local Edx;
								local Results, Limit;
								local B;
								local A;
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Upvalues[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
								Top = (Limit + A) - 1;
								Edx = 0;
								for Idx = A, Top do
									Edx = Edx + 1;
									Stk[Idx] = Results[Edx];
								end
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								if Stk[Inst[2]] then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							else
								local T;
								local Edx;
								local Results, Limit;
								local A;
								Stk[Inst[2]] = Upvalues[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Upvalues[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Upvalues[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Upvalues[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
								Top = (Limit + A) - 1;
								Edx = 0;
								for Idx = A, Top do
									local FlatIdent_43BEE = 0;
									while true do
										if (0 == FlatIdent_43BEE) then
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
											break;
										end
									end
								end
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								T = Stk[A];
								for Idx = A + 1, Top do
									Insert(T, Stk[Idx]);
								end
							end
						elseif (Enum <= 37) then
							if (Enum == 36) then
								local Edx;
								local Results;
								local B;
								local A;
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Stk[A + 1]);
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Results = {Stk[A](Stk[A + 1])};
								Edx = 0;
								for Idx = A, Inst[4] do
									local FlatIdent_2BE68 = 0;
									while true do
										if (FlatIdent_2BE68 == 0) then
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
											break;
										end
									end
								end
								VIP = VIP + 1;
								Inst = Instr[VIP];
								VIP = Inst[3];
							else
								local A;
								Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							end
						elseif (Enum > 38) then
							local T;
							local Edx;
							local Results, Limit;
							local A;
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
							Top = (Limit + A) - 1;
							Edx = 0;
							for Idx = A, Top do
								Edx = Edx + 1;
								Stk[Idx] = Results[Edx];
							end
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							T = Stk[A];
							for Idx = A + 1, Top do
								Insert(T, Stk[Idx]);
							end
						else
							local A;
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							VIP = Inst[3];
						end
					elseif (Enum <= 46) then
						if (Enum <= 42) then
							if (Enum <= 40) then
								local B = Inst[3];
								local K = Stk[B];
								for Idx = B + 1, Inst[4] do
									K = K .. Stk[Idx];
								end
								Stk[Inst[2]] = K;
							elseif (Enum == 41) then
								Stk[Inst[2]] = {};
							else
								local A;
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = {};
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							end
						elseif (Enum <= 44) then
							if (Enum == 43) then
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							elseif (Inst[2] == Stk[Inst[4]]) then
								VIP = VIP + 1;
							else
								VIP = Inst[3];
							end
						elseif (Enum == 45) then
							local K;
							local B;
							local A;
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							B = Inst[3];
							K = Stk[B];
							for Idx = B + 1, Inst[4] do
								K = K .. Stk[Idx];
							end
							Stk[Inst[2]] = K;
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
						else
							local FlatIdent_31077 = 0;
							local Edx;
							local Results;
							local Limit;
							local A;
							while true do
								if (FlatIdent_31077 == 5) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									VIP = Inst[3];
									break;
								end
								if (FlatIdent_31077 == 3) then
									A = Inst[2];
									Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
									Top = (Limit + A) - 1;
									Edx = 0;
									for Idx = A, Top do
										Edx = Edx + 1;
										Stk[Idx] = Results[Edx];
									end
									VIP = VIP + 1;
									FlatIdent_31077 = 4;
								end
								if (1 == FlatIdent_31077) then
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_31077 = 2;
								end
								if (FlatIdent_31077 == 2) then
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_31077 = 3;
								end
								if (FlatIdent_31077 == 4) then
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									FlatIdent_31077 = 5;
								end
								if (FlatIdent_31077 == 0) then
									Edx = nil;
									Results, Limit = nil;
									A = nil;
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_31077 = 1;
								end
							end
						end
					elseif (Enum <= 49) then
						if (Enum <= 47) then
							local FlatIdent_6DFD9 = 0;
							local A;
							local Results;
							local Limit;
							local Edx;
							while true do
								if (2 == FlatIdent_6DFD9) then
									for Idx = A, Top do
										local FlatIdent_229D1 = 0;
										while true do
											if (FlatIdent_229D1 == 0) then
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
												break;
											end
										end
									end
									break;
								end
								if (FlatIdent_6DFD9 == 0) then
									A = Inst[2];
									Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Top)));
									FlatIdent_6DFD9 = 1;
								end
								if (FlatIdent_6DFD9 == 1) then
									Top = (Limit + A) - 1;
									Edx = 0;
									FlatIdent_6DFD9 = 2;
								end
							end
						elseif (Enum == 48) then
							local K;
							local B;
							local Edx;
							local Results, Limit;
							local A;
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Upvalues[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
							Top = (Limit + A) - 1;
							Edx = 0;
							for Idx = A, Top do
								Edx = Edx + 1;
								Stk[Idx] = Results[Edx];
							end
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Upvalues[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							B = Inst[3];
							K = Stk[B];
							for Idx = B + 1, Inst[4] do
								K = K .. Stk[Idx];
							end
							Stk[Inst[2]] = K;
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
						else
							local FlatIdent_71E8F = 0;
							local A;
							while true do
								if (FlatIdent_71E8F == 5) then
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									break;
								end
								if (FlatIdent_71E8F == 2) then
									Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									FlatIdent_71E8F = 3;
								end
								if (FlatIdent_71E8F == 1) then
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_71E8F = 2;
								end
								if (FlatIdent_71E8F == 3) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									FlatIdent_71E8F = 4;
								end
								if (FlatIdent_71E8F == 4) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_71E8F = 5;
								end
								if (FlatIdent_71E8F == 0) then
									A = nil;
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_71E8F = 1;
								end
							end
						end
					elseif (Enum <= 51) then
						if (Enum == 50) then
							local A = Inst[2];
							local T = Stk[A];
							for Idx = A + 1, Top do
								Insert(T, Stk[Idx]);
							end
						else
							Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
						end
					elseif (Enum == 52) then
						local FlatIdent_98327 = 0;
						local A;
						while true do
							if (FlatIdent_98327 == 1) then
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								FlatIdent_98327 = 2;
							end
							if (FlatIdent_98327 == 3) then
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								FlatIdent_98327 = 4;
							end
							if (FlatIdent_98327 == 4) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								if (Stk[Inst[2]] == Stk[Inst[4]]) then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
								break;
							end
							if (FlatIdent_98327 == 2) then
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								FlatIdent_98327 = 3;
							end
							if (0 == FlatIdent_98327) then
								A = nil;
								Stk[Inst[2]] = Upvalues[Inst[3]];
								VIP = VIP + 1;
								FlatIdent_98327 = 1;
							end
						end
					else
						local FlatIdent_8A9D7 = 0;
						local B;
						local T;
						local A;
						while true do
							if (FlatIdent_8A9D7 == 1) then
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
								FlatIdent_8A9D7 = 2;
							end
							if (3 == FlatIdent_8A9D7) then
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_8A9D7 = 4;
							end
							if (FlatIdent_8A9D7 == 6) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								FlatIdent_8A9D7 = 7;
							end
							if (FlatIdent_8A9D7 == 8) then
								A = Inst[2];
								T = Stk[A];
								B = Inst[3];
								for Idx = 1, B do
									T[Idx] = Stk[A + Idx];
								end
								break;
							end
							if (FlatIdent_8A9D7 == 4) then
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								FlatIdent_8A9D7 = 5;
							end
							if (FlatIdent_8A9D7 == 0) then
								B = nil;
								T = nil;
								A = nil;
								A = Inst[2];
								FlatIdent_8A9D7 = 1;
							end
							if (FlatIdent_8A9D7 == 5) then
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = {};
								FlatIdent_8A9D7 = 6;
							end
							if (FlatIdent_8A9D7 == 7) then
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_8A9D7 = 8;
							end
							if (FlatIdent_8A9D7 == 2) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								FlatIdent_8A9D7 = 3;
							end
						end
					end
				elseif (Enum <= 80) then
					if (Enum <= 66) then
						if (Enum <= 59) then
							if (Enum <= 56) then
								if (Enum <= 54) then
									local A;
									Stk[Inst[2]] = {};
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
								elseif (Enum == 55) then
									Stk[Inst[2]] = #Stk[Inst[3]];
								else
									local A = Inst[2];
									Stk[A](Stk[A + 1]);
								end
							elseif (Enum <= 57) then
								local A;
								Stk[Inst[2]] = {};
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
							elseif (Enum > 58) then
								local Edx;
								local Results, Limit;
								local A;
								Stk[Inst[2]] = Upvalues[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
								Top = (Limit + A) - 1;
								Edx = 0;
								for Idx = A, Top do
									Edx = Edx + 1;
									Stk[Idx] = Results[Edx];
								end
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								if Stk[Inst[2]] then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							else
								VIP = Inst[3];
							end
						elseif (Enum <= 62) then
							if (Enum <= 60) then
								if Stk[Inst[2]] then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							elseif (Enum > 61) then
								local A;
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							else
								Stk[Inst[2]] = Stk[Inst[3]];
							end
						elseif (Enum <= 64) then
							if (Enum == 63) then
								local FlatIdent_15034 = 0;
								local Edx;
								local Results;
								local Limit;
								local A;
								while true do
									if (1 == FlatIdent_15034) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_15034 = 2;
									end
									if (FlatIdent_15034 == 6) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										if Stk[Inst[2]] then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
										break;
									end
									if (0 == FlatIdent_15034) then
										Edx = nil;
										Results, Limit = nil;
										A = nil;
										Stk[Inst[2]] = Upvalues[Inst[3]];
										FlatIdent_15034 = 1;
									end
									if (FlatIdent_15034 == 2) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_15034 = 3;
									end
									if (3 == FlatIdent_15034) then
										A = Inst[2];
										Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
										Top = (Limit + A) - 1;
										Edx = 0;
										FlatIdent_15034 = 4;
									end
									if (4 == FlatIdent_15034) then
										for Idx = A, Top do
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
										end
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										FlatIdent_15034 = 5;
									end
									if (FlatIdent_15034 == 5) then
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										FlatIdent_15034 = 6;
									end
								end
							else
								local A = Inst[2];
								local Results, Limit = _R(Stk[A](Stk[A + 1]));
								Top = (Limit + A) - 1;
								local Edx = 0;
								for Idx = A, Top do
									Edx = Edx + 1;
									Stk[Idx] = Results[Edx];
								end
							end
						elseif (Enum > 65) then
							for Idx = Inst[2], Inst[3] do
								Stk[Idx] = nil;
							end
						else
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							do
								return;
							end
						end
					elseif (Enum <= 73) then
						if (Enum <= 69) then
							if (Enum <= 67) then
								local FlatIdent_74B46 = 0;
								local B;
								local A;
								while true do
									if (FlatIdent_74B46 == 1) then
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										FlatIdent_74B46 = 2;
									end
									if (FlatIdent_74B46 == 2) then
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										FlatIdent_74B46 = 3;
									end
									if (FlatIdent_74B46 == 5) then
										Inst = Instr[VIP];
										if Stk[Inst[2]] then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
										break;
									end
									if (FlatIdent_74B46 == 0) then
										B = nil;
										A = nil;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										FlatIdent_74B46 = 1;
									end
									if (FlatIdent_74B46 == 4) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										FlatIdent_74B46 = 5;
									end
									if (FlatIdent_74B46 == 3) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										FlatIdent_74B46 = 4;
									end
								end
							elseif (Enum == 68) then
								local Edx;
								local Results, Limit;
								local B;
								local A;
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Upvalues[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
								Top = (Limit + A) - 1;
								Edx = 0;
								for Idx = A, Top do
									local FlatIdent_340E5 = 0;
									while true do
										if (FlatIdent_340E5 == 0) then
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
											break;
										end
									end
								end
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								if Stk[Inst[2]] then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							else
								local A = Inst[2];
								local Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
								Top = (Limit + A) - 1;
								local Edx = 0;
								for Idx = A, Top do
									local FlatIdent_4BE81 = 0;
									while true do
										if (FlatIdent_4BE81 == 0) then
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
											break;
										end
									end
								end
							end
						elseif (Enum <= 71) then
							if (Enum == 70) then
								local FlatIdent_9525B = 0;
								local A;
								local Index;
								local Step;
								while true do
									if (FlatIdent_9525B == 1) then
										Step = Stk[A + 2];
										if (Step > 0) then
											if (Index > Stk[A + 1]) then
												VIP = Inst[3];
											else
												Stk[A + 3] = Index;
											end
										elseif (Index < Stk[A + 1]) then
											VIP = Inst[3];
										else
											Stk[A + 3] = Index;
										end
										break;
									end
									if (FlatIdent_9525B == 0) then
										A = Inst[2];
										Index = Stk[A];
										FlatIdent_9525B = 1;
									end
								end
							else
								local FlatIdent_12E4E = 0;
								local A;
								while true do
									if (FlatIdent_12E4E == 3) then
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										FlatIdent_12E4E = 4;
									end
									if (FlatIdent_12E4E == 1) then
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										FlatIdent_12E4E = 2;
									end
									if (FlatIdent_12E4E == 2) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										FlatIdent_12E4E = 3;
									end
									if (FlatIdent_12E4E == 0) then
										A = nil;
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_12E4E = 1;
									end
									if (FlatIdent_12E4E == 4) then
										Inst = Instr[VIP];
										VIP = Inst[3];
										break;
									end
								end
							end
						elseif (Enum > 72) then
							local Results;
							local Edx;
							local Results, Limit;
							local B;
							local A;
							Stk[Inst[2]] = Upvalues[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							B = Stk[Inst[3]];
							Stk[A + 1] = B;
							Stk[A] = B[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Results, Limit = _R(Stk[A](Stk[A + 1]));
							Top = (Limit + A) - 1;
							Edx = 0;
							for Idx = A, Top do
								local FlatIdent_1B418 = 0;
								while true do
									if (FlatIdent_1B418 == 0) then
										Edx = Edx + 1;
										Stk[Idx] = Results[Edx];
										break;
									end
								end
							end
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Results = {Stk[A](Unpack(Stk, A + 1, Top))};
							Edx = 0;
							for Idx = A, Inst[4] do
								local FlatIdent_2C195 = 0;
								while true do
									if (FlatIdent_2C195 == 0) then
										Edx = Edx + 1;
										Stk[Idx] = Results[Edx];
										break;
									end
								end
							end
							VIP = VIP + 1;
							Inst = Instr[VIP];
							VIP = Inst[3];
						else
							local FlatIdent_8770C = 0;
							local Step;
							local Index;
							local A;
							while true do
								if (FlatIdent_8770C == 5) then
									A = Inst[2];
									Index = Stk[A];
									Step = Stk[A + 2];
									FlatIdent_8770C = 6;
								end
								if (FlatIdent_8770C == 3) then
									Stk[Inst[2]] = #Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_8770C = 4;
								end
								if (4 == FlatIdent_8770C) then
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_8770C = 5;
								end
								if (6 == FlatIdent_8770C) then
									if (Step > 0) then
										if (Index > Stk[A + 1]) then
											VIP = Inst[3];
										else
											Stk[A + 3] = Index;
										end
									elseif (Index < Stk[A + 1]) then
										VIP = Inst[3];
									else
										Stk[A + 3] = Index;
									end
									break;
								end
								if (FlatIdent_8770C == 2) then
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_8770C = 3;
								end
								if (FlatIdent_8770C == 0) then
									Step = nil;
									Index = nil;
									A = nil;
									FlatIdent_8770C = 1;
								end
								if (FlatIdent_8770C == 1) then
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_8770C = 2;
								end
							end
						end
					elseif (Enum <= 76) then
						if (Enum <= 74) then
							local FlatIdent_FC26 = 0;
							local A;
							while true do
								if (FlatIdent_FC26 == 0) then
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									break;
								end
							end
						elseif (Enum == 75) then
							local Edx;
							local Results, Limit;
							local B;
							local A;
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A]();
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							B = Stk[Inst[3]];
							Stk[A + 1] = B;
							Stk[A] = B[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
							Top = (Limit + A) - 1;
							Edx = 0;
							for Idx = A, Top do
								local FlatIdent_98E39 = 0;
								while true do
									if (0 == FlatIdent_98E39) then
										Edx = Edx + 1;
										Stk[Idx] = Results[Edx];
										break;
									end
								end
							end
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Top)));
							Top = (Limit + A) - 1;
							Edx = 0;
							for Idx = A, Top do
								Edx = Edx + 1;
								Stk[Idx] = Results[Edx];
							end
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A]();
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							B = Stk[Inst[3]];
							Stk[A + 1] = B;
							Stk[A] = B[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = {};
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = {};
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Stk[Inst[3]]] = Inst[4];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Stk[Inst[3]]] = Inst[4];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							B = Stk[Inst[3]];
							Stk[A + 1] = B;
							Stk[A] = B[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
						else
							local A;
							Stk[Inst[2]] = Stk[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Stk[Inst[3]]] = Inst[4];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Stk[Inst[3]]] = Inst[4];
						end
					elseif (Enum <= 78) then
						if (Enum == 77) then
							local FlatIdent_8E3FD = 0;
							local K;
							local B;
							local A;
							while true do
								if (1 == FlatIdent_8E3FD) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									FlatIdent_8E3FD = 2;
								end
								if (FlatIdent_8E3FD == 2) then
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									FlatIdent_8E3FD = 3;
								end
								if (4 == FlatIdent_8E3FD) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_8E3FD = 5;
								end
								if (FlatIdent_8E3FD == 3) then
									Inst = Instr[VIP];
									B = Inst[3];
									K = Stk[B];
									for Idx = B + 1, Inst[4] do
										K = K .. Stk[Idx];
									end
									Stk[Inst[2]] = K;
									FlatIdent_8E3FD = 4;
								end
								if (FlatIdent_8E3FD == 5) then
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									FlatIdent_8E3FD = 6;
								end
								if (FlatIdent_8E3FD == 6) then
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Stk[A + 1]);
									break;
								end
								if (0 == FlatIdent_8E3FD) then
									K = nil;
									B = nil;
									A = nil;
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									FlatIdent_8E3FD = 1;
								end
							end
						else
							local A = Inst[2];
							do
								return Stk[A](Unpack(Stk, A + 1, Inst[3]));
							end
						end
					elseif (Enum > 79) then
						Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
					else
						local FlatIdent_38BA4 = 0;
						local A;
						local Results;
						local Edx;
						while true do
							if (FlatIdent_38BA4 == 1) then
								Edx = 0;
								for Idx = A, Inst[4] do
									Edx = Edx + 1;
									Stk[Idx] = Results[Edx];
								end
								break;
							end
							if (FlatIdent_38BA4 == 0) then
								A = Inst[2];
								Results = {Stk[A](Unpack(Stk, A + 1, Top))};
								FlatIdent_38BA4 = 1;
							end
						end
					end
				elseif (Enum <= 94) then
					if (Enum <= 87) then
						if (Enum <= 83) then
							if (Enum <= 81) then
								local A;
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
							elseif (Enum > 82) then
								local K;
								local B;
								local A;
								Stk[Inst[2]] = Upvalues[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								B = Inst[3];
								K = Stk[B];
								for Idx = B + 1, Inst[4] do
									K = K .. Stk[Idx];
								end
								Stk[Inst[2]] = K;
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								if Stk[Inst[2]] then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							else
								local A = Inst[2];
								local T = Stk[A];
								local B = Inst[3];
								for Idx = 1, B do
									T[Idx] = Stk[A + Idx];
								end
							end
						elseif (Enum <= 85) then
							if (Enum > 84) then
								local A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
							else
								local FlatIdent_2C010 = 0;
								local A;
								while true do
									if (FlatIdent_2C010 == 0) then
										A = Inst[2];
										Stk[A](Unpack(Stk, A + 1, Inst[3]));
										break;
									end
								end
							end
						elseif (Enum == 86) then
							Stk[Inst[2]] = Inst[3] + Stk[Inst[4]];
						else
							local B;
							local A;
							A = Inst[2];
							B = Stk[Inst[3]];
							Stk[A + 1] = B;
							Stk[A] = B[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = {};
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
						end
					elseif (Enum <= 90) then
						if (Enum <= 88) then
							local FlatIdent_1BD19 = 0;
							local A;
							local Results;
							local Edx;
							while true do
								if (FlatIdent_1BD19 == 0) then
									A = Inst[2];
									Results = {Stk[A](Stk[A + 1])};
									FlatIdent_1BD19 = 1;
								end
								if (FlatIdent_1BD19 == 1) then
									Edx = 0;
									for Idx = A, Inst[4] do
										local FlatIdent_4CEEC = 0;
										while true do
											if (FlatIdent_4CEEC == 0) then
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
												break;
											end
										end
									end
									break;
								end
							end
						elseif (Enum > 89) then
							local FlatIdent_67408 = 0;
							local Edx;
							local Results;
							local Limit;
							local A;
							while true do
								if (FlatIdent_67408 == 2) then
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_67408 = 3;
								end
								if (FlatIdent_67408 == 0) then
									Edx = nil;
									Results, Limit = nil;
									A = nil;
									FlatIdent_67408 = 1;
								end
								if (FlatIdent_67408 == 5) then
									Edx = 0;
									for Idx = A, Top do
										local FlatIdent_8384B = 0;
										while true do
											if (FlatIdent_8384B == 0) then
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
												break;
											end
										end
									end
									VIP = VIP + 1;
									FlatIdent_67408 = 6;
								end
								if (FlatIdent_67408 == 6) then
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
									FlatIdent_67408 = 7;
								end
								if (FlatIdent_67408 == 3) then
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_67408 = 4;
								end
								if (FlatIdent_67408 == 7) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									if Stk[Inst[2]] then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
									break;
								end
								if (FlatIdent_67408 == 4) then
									A = Inst[2];
									Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
									Top = (Limit + A) - 1;
									FlatIdent_67408 = 5;
								end
								if (FlatIdent_67408 == 1) then
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_67408 = 2;
								end
							end
						else
							local Edx;
							local Results, Limit;
							local A;
							Stk[Inst[2]] = Upvalues[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
							Top = (Limit + A) - 1;
							Edx = 0;
							for Idx = A, Top do
								Edx = Edx + 1;
								Stk[Idx] = Results[Edx];
							end
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							if Stk[Inst[2]] then
								VIP = VIP + 1;
							else
								VIP = Inst[3];
							end
						end
					elseif (Enum <= 92) then
						if (Enum > 91) then
							if (Stk[Inst[2]] == Stk[Inst[4]]) then
								VIP = VIP + 1;
							else
								VIP = Inst[3];
							end
						else
							local A = Inst[2];
							local C = Inst[4];
							local CB = A + 2;
							local Result = {Stk[A](Stk[A + 1], Stk[CB])};
							for Idx = 1, C do
								Stk[CB + Idx] = Result[Idx];
							end
							local R = Result[1];
							if R then
								Stk[CB] = R;
								VIP = Inst[3];
							else
								VIP = VIP + 1;
							end
						end
					elseif (Enum == 93) then
						Stk[Inst[2]] = Stk[Inst[3]] % Inst[4];
					else
						Stk[Inst[2]][Stk[Inst[3]]] = Inst[4];
					end
				elseif (Enum <= 101) then
					if (Enum <= 97) then
						if (Enum <= 95) then
							Stk[Inst[2]] = Stk[Inst[3]] + Inst[4];
						elseif (Enum > 96) then
							local A;
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = {};
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
						else
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
						end
					elseif (Enum <= 99) then
						if (Enum > 98) then
							local A;
							Stk[Inst[2]] = Stk[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Stk[Inst[3]]] = Inst[4];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]];
						elseif (Stk[Inst[2]] == Inst[4]) then
							VIP = VIP + 1;
						else
							VIP = Inst[3];
						end
					elseif (Enum == 100) then
						local A;
						Stk[Inst[2]] = {};
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Stk[Inst[3]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Inst[3];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Inst[3];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						A = Inst[2];
						Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Stk[Inst[3]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Inst[3];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Inst[3];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						A = Inst[2];
						Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Stk[Inst[3]];
					else
						local A = Inst[2];
						local B = Stk[Inst[3]];
						Stk[A + 1] = B;
						Stk[A] = B[Inst[4]];
					end
				elseif (Enum <= 104) then
					if (Enum <= 102) then
						Stk[Inst[2]] = Env[Inst[3]];
					elseif (Enum == 103) then
						Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
					else
						Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
					end
				elseif (Enum <= 106) then
					if (Enum > 105) then
						Stk[Inst[2]] = Env[Inst[3]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Env[Inst[3]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Env[Inst[3]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Env[Inst[3]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						if not Stk[Inst[2]] then
							VIP = VIP + 1;
						else
							VIP = Inst[3];
						end
					else
						local B;
						local A;
						Stk[Inst[2]] = Upvalues[Inst[3]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						A = Inst[2];
						B = Stk[Inst[3]];
						Stk[A + 1] = B;
						Stk[A] = B[Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Stk[Inst[3]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						A = Inst[2];
						Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Upvalues[Inst[3]] = Stk[Inst[2]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						VIP = Inst[3];
					end
				elseif (Enum == 107) then
					local FlatIdent_63A3A = 0;
					local A;
					local Cls;
					while true do
						if (FlatIdent_63A3A == 1) then
							for Idx = 1, #Lupvals do
								local List = Lupvals[Idx];
								for Idz = 0, #List do
									local Upv = List[Idz];
									local NStk = Upv[1];
									local DIP = Upv[2];
									if ((NStk == Stk) and (DIP >= A)) then
										Cls[DIP] = NStk[DIP];
										Upv[1] = Cls;
									end
								end
							end
							break;
						end
						if (FlatIdent_63A3A == 0) then
							A = Inst[2];
							Cls = {};
							FlatIdent_63A3A = 1;
						end
					end
				else
					local FlatIdent_70C30 = 0;
					local A;
					while true do
						if (FlatIdent_70C30 == 0) then
							A = Inst[2];
							do
								return Unpack(Stk, A, Top);
							end
							break;
						end
					end
				end
				VIP = VIP + 1;
			end
		end;
	end
	return Wrap(Deserialize(), {}, vmenv)(...);
end
return VMCall("LOL!923O0003063O00737472696E6703043O006368617203043O00627974652O033O0073756203053O0062697433322O033O0062697403043O0062786F7203053O007461626C6503063O00636F6E63617403063O00696E7365727403073O0067657467656E76030A3O005365637572654D6F64652O01030A3O006C6F6164737472696E6703043O0067616D6503073O00482O7470476574031C3O00D9D7CF35F5E18851C2CAC92CF3A88913D4CDCE6AF4BADE18D8C6D72103083O007EB1A3BB4586DBA7030C3O0043726561746557696E646F7703043O000DCC27C003053O009C43AD4AA5030C3O0006837956F16660119B7A259603073O002654D72976DC46030C3O007C192316F75E11161BEA5C1303053O009E30764272030D3O00990B3276478DDEEB143C17508003073O009BCB44705613C5030F3O006AD237F84976E2CB53DF22F55474E003083O009826BD569C20188503093O00FE4EE740F95BB455F603043O00269C37C703133O008B2O722E1A73EF51A96975271D47FB55A1737B03083O0023C81D1C4873149A03073O003CB1D0DD81293003073O005479DFB1BFED4C0100030A3O009D59C5A43F421EC0B65303083O00A1DB36A9C05A305003093O006C713006464C062C4E03043O004529226003083O009ACADB0F2C2AB1C603063O004BDCA3B76A6203093O00308EBB14D60CBC823003053O00B962DAEB5703093O00E0393ED5C7B9DF392A03063O00CAAB5C4786BE03093O0043726561746554616203043O0004C0258603043O00E849A14C022O00E0E4A6B3F0412O033O009EEA7203053O007EDBB9223D03063O0069706169727303053O00E7CCE14C8503043O003CB4A48E03053O006B560A397503073O0072383E6549478D03053O008BE12OD4EB03043O00A4D889BB03053O00E1EE3EA2F203073O006BB28651D2C69E030C3O00437265617465546F2O676C6503043O00160F8FC303053O00CA586EE2A6030B3O00F70085F02OC64FA7C4FA8303053O00AAA36FE297030C3O003225A02A4B393D2731BE2D4B03073O00497150D2582E5703043O00A720CC1503053O0087E14CAD72030A3O002EE2BFB7A0B88229DD8703073O00C77A8DD8D0CCDD03083O008EDC1CFC7AF7AED603063O0096CDBD709018030C3O0043726561746542752O746F6E03043O000B85B24903083O007045E4DF2C64E871030A3O00F21E14C7F64F92D11E0B03073O00E6B47F67B3D61C03083O00AF04534AE640E38703073O0080EC653F268421030C3O00437265617465536C6964657203043O0082A81C4103073O00AFCCC97124D68B030F3O0070CD39D73757C930D84465C33BC91703053O006427AC55BC03053O009F79B7873603053O0053CD18D9E0028O00025O0080514003093O00CFCBCE2FE32OC833F203043O005D86A5AD026O00F03F03063O008DE7C7C433D603083O001EDE92A1A25AAED2034O00030C3O00C65B6218E040643CE442650F03043O006A852E10027O004003043O007E2C72FB03063O00203840139C3A030E3O006DC9E95D69E2855FCCC75954E79303073O00E03AA885363A9203083O007A5747F17787840003083O006B39362B9D15E6E7030A3O0047657453657276696365030A3O0079C6B67F1E6F5DDABB4903063O001D2BB3D82C7B03043O002FE6455A03053O00136187283F03063O0080533037262103063O0051CE3C535B4F030C3O006DBEC2602ACD59924FA7C57703083O00C42ECBB0124FA32D03043O009E2E7F1903073O008FD8421E7E449B030C3O0084C70EC7CCB3E3EEADCF01CE03083O0081CAA86DABA5C3B703083O0001593BD4DC15E52903073O0086423857B8BE7403053O000C340DA91603083O00555C5169DB798B41030A3O00DCB053406FCCDEB2424103063O00BF9DD330251C030A3O00F21EFA1D3DDA0DDF192303053O005ABF7F947C030B3O004B843C126F833C1E6E823C03043O007718E74E03043O00AC2CA84F03073O0071E24DC52ABC2003043O001D13E0F503043O00D55A769403083O00782FB85A4F5A2DBF03053O002D3B4ED43603043O003E572O8E03083O00907036E3EBE64ECD03113O00923D1BF3904BBA2B04E9C01BB02706F2C303063O003BD3486F9CB003083O006D86EF214C86E02603043O004D2EE78303043O00058D3DA903073O00564BEC50CCC9DD030C3O005B4F6491FF8566014480F28703063O00EB122117E59E03083O0073BBCDB752BBC2B003043O00DB30DAA10082012O00126A3O00013O00206O000200122O000100013O00202O00010001000300122O000200013O00202O00020002000400122O000300053O00062O0003000A0001000100043A3O000A0001001266000300063O002050000400030007001266000500083O002050000500050009001266000600083O00205000060006000A00060B00073O000100062O003D3O00054O003D3O00064O003D8O003D3O00044O003D3O00014O003D3O00023O00124B0008000B6O00080001000200302O0008000C000D00122O0008000E3O00122O0009000F3O00202O0009000900104O000B00073O00122O000C00113O00122O000D00126O000B000D6O00098O00083O00024O00080001000200202O0009000800134O000B3O00054O000C00073O00122O000D00143O00122O000E00156O000C000E00024O000D00073O00122O000E00163O00122O000F00176O000D000F00024O000B000C000D4O000C00073O00122O000D00183O00122O000E00196O000C000E00024O000D00073O00122O000E001A3O00122O000F001B6O000D000F00024O000B000C000D4O000C00073O00122O000D001C3O00122O000E001D6O000C000E00024O000D00073O00122O000E001E3O00122O000F001F6O000D000F00024O000B000C000D4O000C00073O00122O000D00203O00122O000E00216O000C000E00024O000D3O00034O000E00073O00122O000F00223O00122O001000236O000E0010000200202O000D000E00244O000E00073O00122O000F00253O00122O001000266O000E001000024O000F00073O00122O001000273O00122O001100286O000F001100024O000D000E000F4O000E00073O00122O000F00293O00122O0010002A6O000E001000024O000F00073O00122O0010002B3O00122O0011002C6O000F001100024O000D000E000F4O000B000C000D4O000C00073O00122O000D002D3O00122O000E002E6O000C000E000200202O000B000C00244O0009000B000200202O000A0009002F4O000C00073O00122O000D00303O001213000E00316O000C000E000200122O000D00326O000A000D000200202O000B0009002F4O000D00073O00122O000E00333O00122O000F00346O000D000F000200122O000E00324O004A000B000E000200060B000C0001000100012O003D3O00073O00060B000D0002000100012O003D3O00073O00122A000E00356O000F00036O001000073O00122O001100363O00122O001200376O0010001200024O001100073O00122O001200383O00122O001300396O0011001300022O003D001200073O0012270013003A3O00122O0014003B6O0012001400024O001300073O00122O0014003C3O00122O0015003D6O001300156O000F3O00012O0058000E0002001000043A3O00B200010020650013000B003E2O003900153O00044O001600073O00122O0017003F3O00122O001800406O0016001800024O001700073O00122O001800413O00122O001900426O0017001900024O001800124O00280017001700182O00250015001600174O001600073O00122O001700433O00122O001800446O00160018000200205E0015001600242O003D001600073O00121F001700453O00121F001800464O004A0016001800022O003D001700073O00122D001800473O00122O001900486O0017001900024O001800126O0017001700184O0015001600174O001600073O00122O001700493O00122O0018004A6O00160018000200060B00170003000100032O003D3O000C4O003D3O00124O003D3O000D4O00330015001600172O00540013001500012O006B00115O00065B000E008A0001000200043A3O008A0001002065000E000A004B2O003600103O00024O001100073O00122O0012004C3O00122O0013004D6O0011001300024O001200073O00122O0013004E3O00122O0014004F6O0012001400024O0010001100122O003D001100073O00121F001200503O00121F001300514O004A00110013000200021E001200044O00150010001100124O000E0010000100202O000E000A00524O00103O00074O001100073O00122O001200533O00122O001300546O0011001300024O001200073O00122O001300553O001231001400566O0012001400024O0010001100124O001100073O00122O001200573O00122O001300586O0011001300022O0029001200023O00121F001300593O00121F0014005A4O00520012000200012O00330010001100122O004C001100073O00122O0012005B3O00122O0013005C6O00110013000200202O00100011005D4O001100073O00122O0012005E3O00122O0013005F6O00110013000200202O0010001100602O0063001100073O00122O001200613O00122O001300626O00110013000200202O0010001100634O001100073O00122O001200643O00122O001300656O0011001300024O001200073O00121F001300663O001231001400676O0012001400024O0010001100124O001100073O00122O001200683O00122O001300696O00110013000200060B00120005000100012O003D3O00074O00040010001100124O000E0010000100122O000E000F3O00202O000E000E006A4O001000073O00122O0011006B3O00122O0012006C6O001000126O000E3O00024O000F6O0042001000104O000A00115O00060B00120006000100052O003D3O00114O003D3O00074O003D3O000F4O003D3O00104O003D3O000E3O0020570013000A003E4O00153O00044O001600073O00122O0017006D3O00122O0018006E6O0016001800024O001700073O00122O0018006F3O00122O001900706O0017001900022O00250015001600174O001600073O00122O001700713O00122O001800726O00160018000200205E0015001600242O003D001600073O00121F001700733O00121F001800744O004A0016001800022O003D001700073O00121F001800753O001231001900766O0017001900024O0015001600174O001600073O00122O001700773O00122O001800786O00160018000200060B00170007000100012O003D3O00124O00330015001600172O005400130015000100021E001300083O00122A001400356O001500036O001600073O00122O001700793O00122O0018007A6O0016001800024O001700073O00122O0018007B3O00122O0019007C6O0017001900022O003D001800073O0012270019007D3O00122O001A007E6O0018001A00024O001900073O00122O001A007F3O00122O001B00806O0019001B6O00153O00012O005800140002001600043A3O00582O010020650019000A004B2O0039001B3O00024O001C00073O00122O001D00813O00122O001E00826O001C001E00024O001D00073O00122O001E00833O00122O001F00846O001D001F00024O001E00184O0028001D001D001E2O0025001B001C001D4O001C00073O00122O001D00853O00122O001E00866O001C001E000200060B001D0009000100022O003D3O00134O003D3O00184O0033001B001C001D2O00540019001B00012O006B00175O00065B001400412O01000200043A3O00412O010020650014000A004B2O003600163O00024O001700073O00122O001800873O00122O001900886O0017001900024O001800073O00122O001900893O00122O001A008A6O0018001A00024O0016001700182O003D001700073O00121F0018008B3O00121F0019008C4O004A00170019000200060B0018000A000100012O003D3O00074O00150016001700184O00140016000100202O0014000A004B4O00163O00024O001700073O00122O0018008D3O00122O0019008E6O0017001900024O001800073O00122O0019008F3O001231001A00906O0018001A00024O0016001700184O001700073O00122O001800913O00122O001900926O00170019000200060B0018000B000100012O003D3O00074O00330016001700182O00540014001600012O006B8O00193O00013O000C3O00033O00028O00026O00F03F026O007040023C3O00121F000200014O0042000300033O00121F000400013O002662000400030001000100043A3O000300010026620002000B0001000200043A3O000B00012O000900056O003D000600034O004E000500064O006C00055O002662000200020001000100043A3O0002000100121F000500013O000E2C000100330001000500043A3O003300012O002900066O0048000300063O00122O000600026O00075O00122O000800023O00042O0006003200012O0009000A00014O0017000B00036O000C00026O000D00036O000E00046O000F00056O00108O001100093O00202O0012000900024O000F00126O000E3O00024O000F00046O001000056O001100016O001200016O00120009001200102O0012000200124O001300016O00130009001300102O00130002001300202O0013001300024O001000136O000F8O000D3O000200202O000D000D00034O000C000D6O000A3O000100041800060016000100121F000500023O0026620005000E0001000200043A3O000E000100121F000200023O00043A3O0002000100043A3O000E000100043A3O0002000100043A3O0003000100043A3O000200012O00193O00017O00283O00028O00026O00F03F03093O00576F726B737061636503053O0053686F707303043O004E706373030B3O004765744368696C6472656E03053O007061697273027O0040026O00104003163O00546578745374726F6B655472616E73706172656E637903063O00506172656E7403083O00496E7374616E63652O033O006E657703093O0024C7597A727EF4EF1803083O00876CAE3E121E179303043O004E616D65030A3O009EE02DC314A734CFA2D603083O00A7D6894AAB78CE53030C3O004F75746C696E65436F6C6F7203063O00436F6C6F723303133O004F75746C696E655472616E73706172656E6379026O00E03F026O00084003043O0053697A6503053O005544696D3203163O004261636B67726F756E645472616E73706172656E637903043O0054657874030A3O0054657874436F6C6F7233030B3O0053747564734F2O6673657403073O00566563746F7233030B3O00416C776179734F6E546F702O0103093O00F3516800951FC5517C03063O007EA7341074D9030C3O0029269A05061BBC070614BC2703043O004B6776D9026O005940026O004940030C3O00A9F93E51FAA88AE2367AEDAE03063O00C7EB90523D9801D03O00121F000100014O0042000200033O002662000100C90001000200043A3O00C90001000E2C000100040001000200043A3O00040001001266000400033O0020240004000400044O000400043O00202O00040004000500202O0004000400064O0004000200024O000300043O00122O000400076O000500036O00040002000600044O00C4000100121F000900014O0042000A000D3O002662000900AA0001000800043A3O00AA0001000E2C0009001A0001000A00043A3O001A0001003014000D000A0001001067000D000B000C00043A3O00C40001000E2C000100450001000A00043A3O0045000100121F000E00014O0042000F000F3O002662000E001E0001000100043A3O001E000100121F000F00013O002662000F00250001000800043A3O0025000100121F000A00023O00043A3O00450001002662000F00370001000100043A3O003700010012660010000C3O00203000100010000D4O00115O00122O0012000E3O00122O0013000F6O001100136O00103O00024O000B00106O00105O00122O001100113O00122O001200126O00100012000200202O0011000800104O00100010001100102O000B0010001000122O000F00023O000E2C000200210001000F00043A3O00210001001266001000143O002O2000100010000D00122O001100023O00122O001200023O00122O001300026O00100013000200102O000B0013001000302O000B0015001600122O000F00083O00044O0021000100043A3O0045000100043A3O001E0001002662000A00650001001700043A3O0065000100121F000E00013O002662000E00540001000100043A3O00540001001266000F00193O002051000F000F000D00122O001000023O00122O001100013O00122O001200023O00122O001300016O000F0013000200102O000D0018000F00302O000D001A000200122O000E00023O000E2C000800580001000E00043A3O0058000100121F000A00093O00043A3O00650001002662000E00480001000200043A3O00480001002050000F00080010001026000D001B000F00122O000F00143O00202O000F000F000D00122O001000023O00122O001100023O00122O001200026O000F0012000200102O000D001C000F00122O000E00083O00044O00480001002662000A00840001000800043A3O0084000100121F000E00013O002662000E006C0001000800043A3O006C000100121F000A00173O00043A3O00840001000E2C000100770001000E00043A3O00770001001266000F001E3O00202O000F000F000D00122O001000013O00122O001100173O00122O001200016O000F0012000200102O000C001D000F00302O000C001F002000122O000E00023O002662000E00680001000200043A3O00680001001067000C000B0008001208000F000C3O00202O000F000F000D4O00105O00122O001100213O00122O001200226O001000126O000F3O00024O000D000F3O00122O000E00083O00044O00680001002662000A00150001000200043A3O0015000100121F000E00013O002662000E008B0001000800043A3O008B000100121F000A00083O00043A3O00150001000E2C0002009B0001000E00043A3O009B00012O0009000F5O00121A001000233O00122O001100246O000F0011000200102O000C0010000F00122O000F00193O00202O000F000F000D00122O001000013O00122O001100253O00122O001200013O00122O001300266O000F0013000200102O000C0018000F00122O000E00083O002662000E00870001000100043A3O00870001001067000B000B0008001208000F000C3O00202O000F000F000D4O00105O00122O001100273O00122O001200286O001000126O000F3O00024O000C000F3O00122O000E00023O00044O0087000100043A3O0015000100043A3O00C40001002662000900B70001000100043A3O00B7000100121F000E00013O002662000E00B20001000100043A3O00B2000100121F000A00014O0042000B000B3O00121F000E00023O002662000E00AD0001000200043A3O00AD000100121F000900023O00043A3O00B7000100043A3O00AD0001002662000900130001000200043A3O0013000100121F000E00013O002662000E00BE0001000200043A3O00BE000100121F000900083O00043A3O00130001002662000E00BA0001000100043A3O00BA00012O0042000C000D3O00121F000E00023O00043A3O00BA000100043A3O0013000100065B000400110001000200043A3O0011000100043A3O00CF000100043A3O0004000100043A3O00CF0001002662000100020001000100043A3O0002000100121F000200014O0042000300033O00121F000100023O00043A3O000200012O00193O00017O00113O00028O00026O00F03F03093O00576F726B737061636503053O0053686F707303043O004E706373030B3O004765744368696C6472656E03053O007061697273030E3O0046696E6446697273744368696C64030A3O00E02O2788B810FBC03A1F03073O009CA84E40E0D47903043O004E616D65030A3O002FE7A2C60BE7A2C613D103043O00AE678EC503073O0044657374726F79030C3O0078187C162453FD7A295D3D2903073O009836483F58453E030C3O004E50434E616D654C6162656C01463O00121F000100014O0042000200033O002662000100070001000100043A3O0007000100121F000200014O0042000300033O00121F000100023O002662000100020001000200043A3O00020001002662000200090001000100043A3O00090001001266000400033O0020240004000400044O000400043O00202O00040004000500202O0004000400064O0004000200024O000300043O00122O000400076O000500036O00040002000600044O003F000100121F000900014O0042000A000A3O002662000900180001000100043A3O0018000100121F000A00013O002662000A001B0001000100043A3O001B0001002065000B000800082O0053000D5O00122O000E00093O00122O000F000A6O000D000F000200202O000E0008000B4O000D000D000E4O000B000D000200062O000B003000013O00043A3O003000012O0009000B5O00124D000C000C3O00122O000D000D6O000B000D000200202O000C0008000B4O000B000B000C4O000B0008000B00202O000B000B000E4O000B00020001002065000B000800082O003B000D5O00122O000E000F3O00122O000F00106O000D000F6O000B3O000200062O000B003F00013O00043A3O003F0001002050000B00080011002065000B000B000E2O0038000B0002000100043A3O003F000100043A3O001B000100043A3O003F000100043A3O0018000100065B000400160001000200043A3O0016000100043A3O0045000100043A3O0009000100043A3O0045000100043A3O000200012O00193O00019O002O00010A3O00063C3O000600013O00043A3O000600012O000900016O0009000200014O003800010002000100043A3O000900012O0009000100024O0009000200014O00380001000200012O00193O00017O000D3O00028O00026O00F03F03083O00506F77657275707303093O0046617374537465616C03063O0041637469766503053O0056616C75652O0103043O0067616D6503073O00506C6179657273030B3O004C6F63616C506C6179657203063O00537461747573030F3O00537465616C53702O6564426F6E7573026O004940002B3O00121F3O00014O0042000100023O000E2C0001000700013O00043A3O0007000100121F000100014O0042000200023O00121F3O00023O000E2C0002000200013O00043A3O00020001002662000100100001000200043A3O0010000100205000030002000300205000030003000400205000030003000500301400030006000700043A3O002A0001000E2C000100090001000100043A3O0009000100121F000300014O0042000400043O002662000300140001000100043A3O0014000100121F000400013O002662000400200001000100043A3O00200001001266000500083O00206000050005000900202O00020005000A00202O00050002000B00202O00050005000C00302O00050006000D00122O000400023O002662000400170001000200043A3O0017000100121F000100023O00043A3O0009000100043A3O0017000100043A3O0009000100043A3O0014000100043A3O0009000100043A3O002A000100043A3O000200012O00193O00017O000D3O00028O00026O00F03F03043O0067616D6503073O00506C6179657273030B3O004C6F63616C506C61796572030E3O0046696E6446697273744368696C6403063O00E89F10E1ACCF03073O00AFBBEB7195D9BC03063O00537461747573030E3O000BAE8D47D0697D39ABA343ED6C6B03073O00185CCFE12C8319030E3O0057616C6B53702O6564426F6E757303053O0056616C756501313O00121F000100014O0042000200033O002662000100220001000200043A3O00220001002662000200040001000100043A3O00040001001266000400033O00205000040004000400205000030004000500063C0003003000013O00043A3O003000010020650004000300062O003B00065O00122O000700073O00122O000800086O000600086O00043O000200062O0004003000013O00043A3O003000010020500004000300090020440004000400064O00065O00122O0007000A3O00122O0008000B6O000600086O00043O000200062O0004003000013O00043A3O0030000100205000040003000900205000040004000C0010670004000D3O00043A3O0030000100043A3O0004000100043A3O00300001002662000100020001000100043A3O0002000100121F000400013O0026620004002A0001000100043A3O002A000100121F000200014O0042000300033O00121F000400023O002662000400250001000200043A3O0025000100121F000100023O00043A3O0002000100043A3O0025000100043A3O000200012O00193O00017O000C3O00028O0003043O0067616D6503073O00506C6179657273030B3O004C6F63616C506C6179657203093O00436861726163746572026O00F03F03073O005374652O70656403073O00436F2O6E656374030A3O00446973636F2O6E65637403063O00697061697273030A3O0043616E436F2O6C6964653O01883O00121F000100014O0042000200023O002662000100020001000100043A3O00020001001266000300023O00205000030003000300205000030003000400205000020003000500063C0002008700013O00043A3O0087000100063C3O004D00013O00043A3O004D000100121F000300014O0042000400063O000E2C000100130001000300043A3O0013000100121F000400014O0042000500053O00121F000300063O0026620003000E0001000600043A3O000E00012O0042000600063O0026620004003C0001000600043A3O003C0001002662000500260001000600043A3O0026000100060B00063O000100042O00098O003D3O00024O00093O00014O00093O00024O0069000700043O00202O00070007000700202O0007000700084O000900066O0007000900024O000700033O00044O00870001002662000500180001000100043A3O0018000100121F000700014O0042000800083O0026620007002A0001000100043A3O002A000100121F000800013O002662000800330001000100043A3O003300012O000A00096O000500096O0042000600063O00121F000800063O0026620008002D0001000600043A3O002D000100121F000500063O00043A3O0018000100043A3O002D000100043A3O0018000100043A3O002A000100043A3O0018000100043A3O00870001002662000400160001000100043A3O0016000100121F000700013O002662000700430001000600043A3O0043000100121F000400063O00043A3O001600010026620007003F0001000100043A3O003F000100121F000500014O0042000600063O00121F000700063O00043A3O003F000100043A3O0016000100043A3O0087000100043A3O000E000100043A3O0087000100121F000300014O0042000400043O0026620003004F0001000100043A3O004F000100121F000400013O002662000400520001000100043A3O005200012O0009000500033O00063C0005007F00013O00043A3O007F000100121F000500014O0042000600063O002662000500590001000100043A3O0059000100121F000600013O002662000600770001000100043A3O0077000100121F000700014O0042000800083O002662000700600001000100043A3O0060000100121F000800013O002662000800700001000100043A3O007000012O0009000900033O00201D0009000900094O00090002000100122O0009000A6O000A00026O00090002000B00044O006D0001003014000D000B000C00065B0009006C0001000200043A3O006C000100121F000800063O002662000800630001000600043A3O0063000100121F000600063O00043A3O0077000100043A3O0063000100043A3O0077000100043A3O006000010026620006005C0001000600043A3O005C00012O002900076O0005000700023O00043A3O007F000100043A3O005C000100043A3O007F000100043A3O005900012O000A000500014O000500055O00043A3O0087000100043A3O0052000100043A3O0087000100043A3O004F000100043A3O0087000100043A3O000200012O00193O00013O00013O000A3O00010003053O007061697273030E3O0047657444657363656E64616E74732O033O0049734103083O009FD833498DD8325803043O002CDDB940030A3O0043616E436F2O6C696465028O0003053O007461626C6503063O00696E73657274002B4O00097O0026623O002A0001000100043A3O002A00012O00093O00013O00063C3O002A00013O00043A3O002A00010012663O00024O0049000100013O00202O0001000100034O000100029O00000200044O002800010020650005000400042O003B000700023O00122O000800053O00122O000900066O000700096O00053O000200062O0005002800013O00043A3O0028000100205000050004000700063C0005002800013O00043A3O0028000100121F000500084O0042000600063O000E2C000800190001000500043A3O0019000100121F000600083O000E2C0008001C0001000600043A3O001C0001003014000400070001001247000700093O00202O00070007000A4O000800036O000900046O00070009000100044O0028000100043A3O001C000100043A3O0028000100043A3O0019000100065B3O000C0001000200043A3O000C00012O00193O00019O002O0001044O000900016O003D00026O00380001000200012O00193O00017O00063O0003043O0067616D6503073O00506C6179657273030B3O004C6F63616C506C61796572030C3O005370656369616C4974656D7303053O0056616C75653O01073O001241000100013O00202O00010001000200202O00010001000300202O0001000100044O000100013O00302O0001000500066O00019O003O00044O00098O0009000100014O00383O000200012O00193O00017O00043O0003093O00576F726B7370616365030C3O00436F2O6C65637461626C6573030A3O004368696C64412O64656403073O00436F2O6E65637400083O0012663O00013O0020505O000200205000013O000300206500010001000400060B00033O000100012O00098O00540001000300012O00193O00013O00013O000C3O002O033O0049734103043O008A55A45403043O0020DA34D603043O004E616D6503043O006D1838A603083O003A2E7751C891D02503063O00434672616D6503043O0067616D6503073O00506C6179657273030B3O004C6F63616C506C6179657203093O0043686172616374657203103O0048756D616E6F6964522O6F745061727401173O00204400013O00014O00035O00122O000400023O00122O000500036O000300056O00013O000200062O0001001600013O00043A3O0016000100205000013O00042O003400025O00122O000300053O00122O000400066O00020004000200062O000100160001000200043A3O00160001001266000100083O00202B00010001000900202O00010001000A00202O00010001000B00202O00010001000C00202O00010001000700104O000700012O00193O00017O00193O00028O0003053O00D77973598A03073O008084111C29BB2F03053O00323A092A0F03053O003D6152665A03053O009F26A45B9403083O0069CC4ECB2BA7377E03053O0096A22C0E4703083O0031C5CA437E7364A703063O00697061697273026O00F03F03093O00576F726B737061636503053O0053686F7073030E3O0046696E6446697273744368696C6403043O00194BDC3A03073O003E573BBF49E03603043O004E70637303053O00C517E3CCF503043O00A987629A030A3O00F8722858CD21C7C6673003073O00A8AB1744349D532O033O00497341030F3O00C463FAB52C208EE068C5BF2A2097E003073O00E7941195CD454D030C3O00486F6C644475726174696F6E00953O00121F3O00014O0042000100013O000E2C0001000200013O00043A3O000200012O0029000200034O002300035O00122O000400023O00122O000500036O0003000500024O00045O00122O000500043O00122O000600056O0004000600024O00055O00122O000600063O00122O000700076O0005000700024O00065O00122O000700083O00122O000800096O000600086O00023O00012O003D000100023O0012660002000A4O003D000300014O005800020002000400043A3O0090000100121F000700014O00420008000A3O0026620007008A0001000B00043A3O008A00012O0042000A000A3O000E2C0001002D0001000800043A3O002D000100121F000B00013O002662000B00270001000B00043A3O0027000100121F0008000B3O00043A3O002D0001002662000B00230001000100043A3O0023000100121F000900014O0042000A000A3O00121F000B000B3O00043A3O00230001000E2C000B00200001000800043A3O002000010026620009002F0001000100043A3O002F0001001266000B000C3O002043000B000B000D00202O000B000B000E4O000D00066O000B000D00024O000A000B3O00062O000A009000013O00043A3O00900001002065000B000A000E2O003B000D5O00122O000E000F3O00122O000F00106O000D000F6O000B3O000200062O000B009000013O00043A3O0090000100121F000B00014O0042000C000E3O002662000B00480001000100043A3O0048000100121F000C00014O0042000D000D3O00121F000B000B3O002662000B00430001000B00043A3O004300012O0042000E000E3O000E2C000100500001000C00043A3O0050000100121F000D00014O0042000E000E3O00121F000C000B3O002662000C004B0001000B00043A3O004B0001002662000D00520001000100043A3O00520001002050000F000A0011002002000F000F000E4O00115O00122O001200123O00122O001300136O001100136O000F3O00024O000E000F3O00062O000E009000013O00043A3O0090000100121F000F00014O0042001000113O002662000F00790001000B00043A3O00790001002662001000620001000100043A3O006200010020650012000E000E2O003F00145O00122O001500143O00122O001600156O001400166O00123O00024O001100123O00062O0011009000013O00043A3O009000010020650012001100162O003B00145O00122O001500173O00122O001600186O001400166O00123O000200062O0012009000013O00043A3O0090000100301400110019000100043A3O0090000100043A3O0062000100043A3O00900001000E2C000100600001000F00043A3O0060000100121F001000014O0042001100113O00121F000F000B3O00043A3O0060000100043A3O0090000100043A3O0052000100043A3O0090000100043A3O004B000100043A3O0090000100043A3O0043000100043A3O0090000100043A3O002F000100043A3O0090000100043A3O0020000100043A3O009000010026620007001D0001000100043A3O001D000100121F000800014O0042000900093O00121F0007000B3O00043A3O001D000100065B0002001B0001000200043A3O001B000100043A3O0094000100043A3O000200012O00193O00017O00", GetFEnv(), ...);

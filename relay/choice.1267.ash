import "relay/choice.ash";


string __genie_version = "2.2.7";

//Allows error checking. The intention behind this design is Errors are passed in to a method. The method then sets the error if anything went wrong.
record Error
{
	boolean was_error;
	string explanation;
};

Error ErrorMake(boolean was_error, string explanation)
{
	Error err;
	err.was_error = was_error;
	err.explanation = explanation;
	return err;
}

Error ErrorMake()
{
	return ErrorMake(false, "");
}

void ErrorSet(Error err, string explanation)
{
	err.was_error = true;
	err.explanation = explanation;
}

void ErrorSet(Error err)
{
	ErrorSet(err, "Unknown");
}

//Coordinate system is upper-left origin.

int INT32_MAX = 2147483647;



float clampf(float v, float min_value, float max_value)
{
	if (v > max_value)
		return max_value;
	if (v < min_value)
		return min_value;
	return v;
}

float clampNormalf(float v)
{
	return clampf(v, 0.0, 1.0);
}

int clampi(int v, int min_value, int max_value)
{
	if (v > max_value)
		return max_value;
	if (v < min_value)
		return min_value;
	return v;
}

float clampNormali(int v)
{
	return clampi(v, 0, 1);
}

//random() will halt the script if range is <= 1, which can happen when picking a random object out of a variable-sized list.
//There's also a hidden bug where values above 2147483647 will be treated as zero.
int random_safe(int range)
{
	if (range < 2 || range > 2147483647)
		return 0;
	return random(range);
}

float randomf()
{
    return random_safe(2147483647).to_float() / 2147483647.0;
}

//to_int will print a warning, but not halt, if you give it a non-int value.
//This function prevents the warning message.
//err is set if value is not an integer.
int to_int_silent(string value, Error err)
{
    //to_int() supports floating-point values. is_integer() will return false.
    //So manually strip out everything past the dot.
    //We probably should just ask for to_int() to be silent in the first place.
    int dot_position = value.index_of(".");
    if (dot_position != -1 && dot_position > 0) //two separate concepts - is it valid, and is it past the first position. I like testing against both, for safety against future changes.
    {
        value = value.substring(0, dot_position);
    }
    
	if (is_integer(value))
        return to_int(value);
    ErrorSet(err, "Unknown integer \"" + value + "\".");
	return 0;
}

int to_int_silent(string value)
{
	return to_int_silent(value, ErrorMake());
}

//Silly conversions in case we chose the wrong function, removing the need for a int -> string -> int hit.
int to_int_silent(int value)
{
    return value;
}

int to_int_silent(float value)
{
    return value;
}


float sqrt(float v, Error err)
{
    if (v < 0.0)
    {
        ErrorSet(err, "Cannot take square root of value " + v + " less than 0.0");
        return -1.0; //mathematically incorrect, but prevents halting. should return NaN
    }
	return square_root(v);
}

float sqrt(float v)
{
    return sqrt(v, ErrorMake());
}

float fabs(float v)
{
    if (v < 0.0)
        return -v;
    return v;
}

int abs(int v)
{
    if (v < 0)
        return -v;
    return v;
}

int ceiling(float v)
{
	return ceil(v);
}

int pow2i(int v)
{
	return v * v;
}

float pow2f(float v)
{
	return v * v;
}

//x^p
float powf(float x, float p)
{
    return x ** p;
}

//x^p
int powi(int x, int p)
{
    return x ** p;
}

record Vec2i
{
	int x; //or width
	int y; //or height
};

Vec2i Vec2iMake(int x, int y)
{
	Vec2i result;
	result.x = x;
	result.y = y;
	
	return result;
}

Vec2i Vec2iCopy(Vec2i v)
{
    return Vec2iMake(v.x, v.y);
}

Vec2i Vec2iZero()
{
	return Vec2iMake(0,0);
}

boolean Vec2iValueInRange(Vec2i v, int value)
{
    if (value >= v.x && value <= v.y)
        return true;
    return false;
}

boolean Vec2iEquals(Vec2i a, Vec2i b)
{
    if (a.x != b.x) return false;
    if (a.y != b.y) return false;
    return true;
}

string Vec2iDescription(Vec2i v)
{
    buffer out;
    out.append("[");
    out.append(v.x);
    out.append(", ");
    out.append(v.y);
    out.append("]");
    return out.to_string();
}

Vec2i Vec2iIntersection(Vec2i a, Vec2i b)
{
    Vec2i result;
    result.x = max(a.x, b.x);
    result.y = min(a.y, b.y);
    return result;
}

boolean Vec2iIntersectsWithVec2i(Vec2i a, Vec2i b)
{
    //Assumed [min, max]:
    if (a.y < b.x) return false;
    if (a.x > b.y) return false;
    return true;
}

record Vec2f
{
	float x; //or width
	float y; //or height
};

Vec2f Vec2fMake(float x, float y)
{
	Vec2f result;
	result.x = x;
	result.y = y;
	
	return result;
}

Vec2f Vec2fCopy(Vec2f v)
{
    return Vec2fMake(v.x, v.y);
}

Vec2f Vec2fZero()
{
	return Vec2fMake(0.0, 0.0);
}

boolean Vec2fValueInRange(Vec2f v, float value)
{
    if (value >= v.x && value <= v.y)
        return true;
    return false;
}

Vec2f Vec2fMultiply(Vec2f v, float c)
{
	return Vec2fMake(v.x * c, v.y * c);
}
Vec2f Vec2fAdd(Vec2f v, float c)
{
    return Vec2fMake(v.x + c, v.y + c);
}
float Vec2fAverage(Vec2f v)
{
    return (v.x + v.y) * 0.5;
}



string Vec2fDescription(Vec2f v)
{
    buffer out;
    out.append("[");
    out.append(v.x);
    out.append(", ");
    out.append(v.y);
    out.append("]");
    return out.to_string();
}


record Rect
{
	Vec2i min_coordinate;
	Vec2i max_coordinate;
};

Rect RectMake(Vec2i min_coordinate, Vec2i max_coordinate)
{
	Rect result;
	result.min_coordinate = Vec2iCopy(min_coordinate);
	result.max_coordinate = Vec2iCopy(max_coordinate);
	return result;
}

Rect RectCopy(Rect r)
{
    return RectMake(r.min_coordinate, r.max_coordinate);
}

Rect RectMake(int min_x, int min_y, int max_x, int max_y)
{
	return RectMake(Vec2iMake(min_x, min_y), Vec2iMake(max_x, max_y));
}

Rect RectZero()
{
	return RectMake(Vec2iZero(), Vec2iZero());
}


void listAppend(Rect [int] list, Rect entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

//Allows for fractional digits, not just whole numbers. Useful for preventing "+233.333333333333333% item"-type output.
//Outputs 3.0, 3.1, 3.14, etc.
float round(float v, int additional_fractional_digits)
{
	if (additional_fractional_digits < 1)
		return v.round().to_float();
	float multiplier = powf(10.0, additional_fractional_digits);
	return to_float(round(v * multiplier)) / multiplier;
}

//Similar to round() addition above, but also converts whole float numbers into integers for output
string roundForOutput(float v, int additional_fractional_digits)
{
	v = round(v, additional_fractional_digits);
	int vi = v.to_int();
	if (vi.to_float() == v)
		return vi.to_string();
	else
		return v.to_string();
}


float floor(float v, int additional_fractional_digits)
{
	if (additional_fractional_digits < 1)
		return v.floor().to_float();
	float multiplier = powf(10.0, additional_fractional_digits);
	return to_float(floor(v * multiplier)) / multiplier;
}

string floorForOutput(float v, int additional_fractional_digits)
{
	v = floor(v, additional_fractional_digits);
	int vi = v.to_int();
	if (vi.to_float() == v)
		return vi.to_string();
	else
		return v.to_string();
}


float TriangularDistributionCalculateCDF(float x, float min, float max, float centre)
{
    //piecewise function:
    if (x < min) return 0.0;
    else if (x > max) return 1.0;
    else if (x >= min && x <= centre)
    {
        float divisor = (max - min) * (centre - min);
        if (divisor == 0.0)
            return 0.0;
        
        return pow2f(x - min) / divisor;
    }
    else if (x <= max && x > centre)
    {
        float divisor = (max - min) * (max - centre);
        if (divisor == 0.0)
            return 0.0;
        
            
        return 1.0 - pow2f(max - x) / divisor;
    }
    else //probably only happens with weird floating point values, assume chance of zero:
        return 0.0;
}

//assume a centre equidistant from min and max
float TriangularDistributionCalculateCDF(float x, float min, float max)
{
    return TriangularDistributionCalculateCDF(x, min, max, (min + max) * 0.5);
}

float averagef(float a, float b)
{
    return (a + b) * 0.5;
}

boolean numberIsInRangeInclusive(int v, int min, int max)
{
    if (v < min) return false;
    if (v > max) return false;
    return true;
}
//WARNING: All listAppend functions are flawed.
//Specifically, there's a possibility of a hole that causes order to be incorrect.
//But, the only way to fix that is to traverse the list to determine the maximum key.
//That would take forever...

string listLastObject(string [int] list)
{
    if (list.count() == 0)
        return "";
    return list[list.count() - 1];
}

void listAppend(string [int] list, string entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

void listAppendList(string [int] list, string [int] entries)
{
	foreach key in entries
		list.listAppend(entries[key]);
}

string [int] listUnion(string [int] list, string [int] list2)
{
    string [int] result;
    foreach key, s in list
        result.listAppend(s);
    foreach key, s in list2
        result.listAppend(s);
    return result;
}

void listAppendList(boolean [item] destination, boolean [item] source)
{
    foreach it, value in source
        destination[it] = value;
}

void listAppendList(boolean [string] destination, boolean [string] source)
{
    foreach key, value in source
        destination[key] = value;
}

void listAppendList(boolean [skill] destination, boolean [skill] source)
{
    foreach key, value in source
        destination[key] = value;
}

void listAppend(item [int] list, item entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

void listAppendList(item [int] list, item [int] entries)
{
	foreach key in entries
        list.listAppend(entries[key]);
}



void listAppend(int [int] list, int entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

void listAppend(float [int] list, float entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

void listAppend(location [int] list, location entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

void listAppend(element [int] list, element entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

void listAppendList(location [int] list, location [int] entries)
{
	foreach key in entries
        list.listAppend(entries[key]);
}

void listAppend(effect [int] list, effect entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

void listAppend(skill [int] list, skill entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

void listAppend(familiar [int] list, familiar entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

void listAppend(monster [int] list, monster entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

void listAppend(phylum [int] list, phylum entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

void listAppend(buffer [int] list, buffer entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

void listAppend(slot [int] list, slot entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

void listAppend(thrall [int] list, thrall entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}





void listAppend(string [int][int] list, string [int] entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

void listAppend(skill [int][int] list, skill [int] entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

void listAppend(familiar [int][int] list, familiar [int] entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

void listAppend(int [int][int] list, int [int] entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

void listAppend(item [int][int] list, item [int] entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

void listAppend(skill [int] list, boolean [skill] entry)
{
    foreach v in entry
        list.listAppend(v);
}

void listAppend(item [int] list, boolean [item] entry)
{
    foreach v in entry
        list.listAppend(v);
}

void listPrepend(string [int] list, string entry)
{
	int position = 0;
	while (list contains position)
		position -= 1;
	list[position] = entry;
}

void listPrepend(skill [int] list, skill entry)
{
	int position = 0;
	while (list contains position)
		position -= 1;
	list[position] = entry;
}

void listAppendList(skill [int] list, skill [int] entries)
{
	foreach key in entries
        list.listAppend(entries[key]);
}

void listPrepend(location [int] list, location entry)
{
	int position = 0;
	while (list contains position)
		position -= 1;
	list[position] = entry;
}

void listPrepend(item [int] list, item entry)
{
    int position = 0;
    while (list contains position)
        position -= 1;
    list[position] = entry;
}


void listClear(string [int] list)
{
	foreach i in list
	{
		remove list[i];
	}
}

void listClear(int [int] list)
{
	foreach i in list
	{
		remove list[i];
	}
}

void listClear(item [int] list)
{
	foreach i in list
	{
		remove list[i];
	}
}

void listClear(location [int] list)
{
	foreach i in list
	{
		remove list[i];
	}
}

void listClear(monster [int] list)
{
	foreach i in list
	{
		remove list[i];
	}
}

void listClear(skill [int] list)
{
	foreach i in list
	{
		remove list[i];
	}
}


void listClear(boolean [string] list)
{
	foreach i in list
	{
		remove list[i];
	}
}


string [int] listMakeBlankString()
{
	string [int] result;
	return result;
}

item [int] listMakeBlankItem()
{
	item [int] result;
	return result;
}

skill [int] listMakeBlankSkill()
{
	skill [int] result;
	return result;
}

location [int] listMakeBlankLocation()
{
	location [int] result;
	return result;
}

monster [int] listMakeBlankMonster()
{
	monster [int] result;
	return result;
}

familiar [int] listMakeBlankFamiliar()
{
	familiar [int] result;
	return result;
}




string [int] listMake(string e1)
{
	string [int] result;
	result.listAppend(e1);
	return result;
}

string [int] listMake(string e1, string e2)
{
	string [int] result;
	result.listAppend(e1);
	result.listAppend(e2);
	return result;
}

string [int] listMake(string e1, string e2, string e3)
{
	string [int] result;
	result.listAppend(e1);
	result.listAppend(e2);
	result.listAppend(e3);
	return result;
}

string [int] listMake(string e1, string e2, string e3, string e4)
{
	string [int] result;
	result.listAppend(e1);
	result.listAppend(e2);
	result.listAppend(e3);
	result.listAppend(e4);
	return result;
}

string [int] listMake(string e1, string e2, string e3, string e4, string e5)
{
	string [int] result;
	result.listAppend(e1);
	result.listAppend(e2);
	result.listAppend(e3);
	result.listAppend(e4);
	result.listAppend(e5);
	return result;
}

string [int] listMake(string e1, string e2, string e3, string e4, string e5, string e6)
{
	string [int] result;
	result.listAppend(e1);
	result.listAppend(e2);
	result.listAppend(e3);
	result.listAppend(e4);
	result.listAppend(e5);
	result.listAppend(e6);
	return result;
}

int [int] listMake(int e1)
{
	int [int] result;
	result.listAppend(e1);
	return result;
}

int [int] listMake(int e1, int e2)
{
	int [int] result;
	result.listAppend(e1);
	result.listAppend(e2);
	return result;
}

int [int] listMake(int e1, int e2, int e3)
{
	int [int] result;
	result.listAppend(e1);
	result.listAppend(e2);
	result.listAppend(e3);
	return result;
}

int [int] listMake(int e1, int e2, int e3, int e4)
{
	int [int] result;
	result.listAppend(e1);
	result.listAppend(e2);
	result.listAppend(e3);
	result.listAppend(e4);
	return result;
}

int [int] listMake(int e1, int e2, int e3, int e4, int e5)
{
	int [int] result;
	result.listAppend(e1);
	result.listAppend(e2);
	result.listAppend(e3);
	result.listAppend(e4);
	result.listAppend(e5);
	return result;
}

item [int] listMake(item e1)
{
	item [int] result;
	result.listAppend(e1);
	return result;
}

item [int] listMake(item e1, item e2)
{
	item [int] result;
	result.listAppend(e1);
	result.listAppend(e2);
	return result;
}

item [int] listMake(item e1, item e2, item e3)
{
	item [int] result;
	result.listAppend(e1);
	result.listAppend(e2);
	result.listAppend(e3);
	return result;
}

item [int] listMake(item e1, item e2, item e3, item e4)
{
	item [int] result;
	result.listAppend(e1);
	result.listAppend(e2);
	result.listAppend(e3);
	result.listAppend(e4);
	return result;
}

item [int] listMake(item e1, item e2, item e3, item e4, item e5)
{
	item [int] result;
	result.listAppend(e1);
	result.listAppend(e2);
	result.listAppend(e3);
	result.listAppend(e4);
	result.listAppend(e5);
	return result;
}

skill [int] listMake(skill e1)
{
	skill [int] result;
	result.listAppend(e1);
	return result;
}

skill [int] listMake(skill e1, skill e2)
{
	skill [int] result;
	result.listAppend(e1);
	result.listAppend(e2);
	return result;
}

skill [int] listMake(skill e1, skill e2, skill e3)
{
	skill [int] result;
	result.listAppend(e1);
	result.listAppend(e2);
	result.listAppend(e3);
	return result;
}

skill [int] listMake(skill e1, skill e2, skill e3, skill e4)
{
	skill [int] result;
	result.listAppend(e1);
	result.listAppend(e2);
	result.listAppend(e3);
	result.listAppend(e4);
	return result;
}

skill [int] listMake(skill e1, skill e2, skill e3, skill e4, skill e5)
{
	skill [int] result;
	result.listAppend(e1);
	result.listAppend(e2);
	result.listAppend(e3);
	result.listAppend(e4);
	result.listAppend(e5);
	return result;
}


monster [int] listMake(monster e1)
{
	monster [int] result;
	result.listAppend(e1);
	return result;
}

monster [int] listMake(monster e1, monster e2)
{
	monster [int] result;
	result.listAppend(e1);
	result.listAppend(e2);
	return result;
}

monster [int] listMake(monster e1, monster e2, monster e3)
{
	monster [int] result;
	result.listAppend(e1);
	result.listAppend(e2);
	result.listAppend(e3);
	return result;
}

monster [int] listMake(monster e1, monster e2, monster e3, monster e4)
{
	monster [int] result;
	result.listAppend(e1);
	result.listAppend(e2);
	result.listAppend(e3);
	result.listAppend(e4);
	return result;
}

monster [int] listMake(monster e1, monster e2, monster e3, monster e4, monster e5)
{
	monster [int] result;
	result.listAppend(e1);
	result.listAppend(e2);
	result.listAppend(e3);
	result.listAppend(e4);
	result.listAppend(e5);
	return result;
}

monster [int] listMake(monster e1, monster e2, monster e3, monster e4, monster e5, monster e6)
{
	monster [int] result;
	result.listAppend(e1);
	result.listAppend(e2);
	result.listAppend(e3);
	result.listAppend(e4);
	result.listAppend(e5);
	result.listAppend(e6);
	return result;
}

string listJoinComponents(string [int] list, string joining_string, string and_string)
{
	buffer result;
	boolean first = true;
	int number_seen = 0;
	foreach i, value in list
	{
		if (first)
		{
			result.append(value);
			first = false;
		}
		else
		{
			if (!(list.count() == 2 && and_string != ""))
				result.append(joining_string);
			if (and_string != "" && number_seen == list.count() - 1)
			{
				result.append(" ");
				result.append(and_string);
				result.append(" ");
			}
			result.append(value);
		}
		number_seen = number_seen + 1;
	}
	return result.to_string();
}

string listJoinComponents(string [int] list, string joining_string)
{
	return listJoinComponents(list, joining_string, "");
}


string listJoinComponents(item [int] list, string joining_string, string and_string)
{
	//lazy:
	//convert items to strings, join that
	string [int] list_string;
	foreach key in list
		list_string.listAppend(list[key].to_string());
	return listJoinComponents(list_string, joining_string, and_string);
}

string listJoinComponents(item [int] list, string joining_string)
{
	return listJoinComponents(list, joining_string, "");
}

string listJoinComponents(monster [int] list, string joining_string, string and_string)
{
	string [int] list_string;
	foreach key in list
		list_string.listAppend(list[key].to_string());
	return listJoinComponents(list_string, joining_string, and_string);
}
string listJoinComponents(monster [int] list, string joining_string)
{
	return listJoinComponents(list, joining_string, "");
}

string listJoinComponents(effect [int] list, string joining_string, string and_string)
{
	string [int] list_string;
	foreach key in list
		list_string.listAppend(list[key].to_string());
	return listJoinComponents(list_string, joining_string, and_string);
}

string listJoinComponents(effect [int] list, string joining_string)
{
	return listJoinComponents(list, joining_string, "");
}


string listJoinComponents(familiar [int] list, string joining_string, string and_string)
{
	string [int] list_string;
	foreach key in list
		list_string.listAppend(list[key].to_string());
	return listJoinComponents(list_string, joining_string, and_string);
}

string listJoinComponents(familiar [int] list, string joining_string)
{
	return listJoinComponents(list, joining_string, "");
}



string listJoinComponents(location [int] list, string joining_string, string and_string)
{
	//lazy:
	//convert locations to strings, join that
	string [int] list_string;
	foreach key in list
		list_string.listAppend(list[key].to_string());
	return listJoinComponents(list_string, joining_string, and_string);
}

string listJoinComponents(location [int] list, string joining_string)
{
	return listJoinComponents(list, joining_string, "");
}

string listJoinComponents(phylum [int] list, string joining_string, string and_string)
{
	string [int] list_string;
	foreach key in list
		list_string.listAppend(list[key].to_string());
	return listJoinComponents(list_string, joining_string, and_string);
}

string listJoinComponents(phylum [int] list, string joining_string)
{
	return listJoinComponents(list, joining_string, "");
}



string listJoinComponents(skill [int] list, string joining_string, string and_string)
{
	string [int] list_string;
	foreach key in list
		list_string.listAppend(list[key].to_string());
	return listJoinComponents(list_string, joining_string, and_string);
}

string listJoinComponents(skill [int] list, string joining_string)
{
	return listJoinComponents(list, joining_string, "");
}

string listJoinComponents(int [int] list, string joining_string, string and_string)
{
	//lazy:
	//convert ints to strings, join that
	string [int] list_string;
	foreach key in list
		list_string.listAppend(list[key].to_string());
	return listJoinComponents(list_string, joining_string, and_string);
}

string listJoinComponents(int [int] list, string joining_string)
{
	return listJoinComponents(list, joining_string, "");
}


void listRemoveKeys(string [int] list, int [int] keys_to_remove)
{
	foreach i in keys_to_remove
	{
		int key = keys_to_remove[i];
		if (!(list contains key))
			continue;
		remove list[key];
	}
}

int listSum(int [int] list)
{
    int v = 0;
    foreach key in list
    {
        v += list[key];
    }
    return v;
}


string [int] listCopy(string [int] l)
{
    string [int] result;
    foreach key in l
        result[key] = l[key];
    return result;
}

int [int] listCopy(int [int] l)
{
    int [int] result;
    foreach key in l
        result[key] = l[key];
    return result;
}

monster [int] listCopy(monster [int] l)
{
    monster [int] result;
    foreach key in l
        result[key] = l[key];
    return result;
}

element [int] listCopy(element [int] l)
{
    element [int] result;
    foreach key in l
        result[key] = l[key];
    return result;
}

skill [int] listCopy(skill [int] l)
{
    skill [int] result;
    foreach key in l
        result[key] = l[key];
    return result;
}

boolean [monster] listCopy(boolean [monster] l)
{
    boolean [monster] result;
    foreach key in l
        result[key] = l[key];
    return result;
}

//Strict, in this case, means the keys start at 0, and go up by one per entry. This allows easy consistent access
boolean listKeysMeetStrictRequirements(string [int] list)
{
    int expected_value = 0;
    foreach key in list
    {
        if (key != expected_value)
            return false;
        expected_value += 1;
    }
    return true;
}
string [int] listCopyStrictRequirements(string [int] list)
{
    string [int] result;
    foreach key in list
        result.listAppend(list[key]);
    return result;
}

string [string] mapMake()
{
	string [string] result;
	return result;
}

string [string] mapMake(string key1, string value1)
{
	string [string] result;
	result[key1] = value1;
	return result;
}

string [string] mapMake(string key1, string value1, string key2, string value2)
{
	string [string] result;
	result[key1] = value1;
	result[key2] = value2;
	return result;
}

string [string] mapMake(string key1, string value1, string key2, string value2, string key3, string value3)
{
	string [string] result;
	result[key1] = value1;
	result[key2] = value2;
	result[key3] = value3;
	return result;
}

string [string] mapMake(string key1, string value1, string key2, string value2, string key3, string value3, string key4, string value4)
{
	string [string] result;
	result[key1] = value1;
	result[key2] = value2;
	result[key3] = value3;
	result[key4] = value4;
	return result;
}

string [string] mapMake(string key1, string value1, string key2, string value2, string key3, string value3, string key4, string value4, string key5, string value5)
{
	string [string] result;
	result[key1] = value1;
	result[key2] = value2;
	result[key3] = value3;
	result[key4] = value4;
	result[key5] = value5;
	return result;
}


string [string] mapMake(string key1, string value1, string key2, string value2, string key3, string value3, string key4, string value4, string key5, string value5, string key6, string value6)
{
	string [string] result;
	result[key1] = value1;
	result[key2] = value2;
	result[key3] = value3;
	result[key4] = value4;
	result[key5] = value5;
	result[key6] = value6;
	return result;
}

string [string] mapCopy(string [string] map)
{
    string [string] result;
    foreach key in map
        result[key] = map[key];
    return result;
}

boolean [string] listInvert(string [int] list)
{
	boolean [string] result;
	foreach key in list
	{
		result[list[key]] = true;
	}
	return result;
}


boolean [int] listInvert(int [int] list)
{
	boolean [int] result;
	foreach key in list
	{
		result[list[key]] = true;
	}
	return result;
}

boolean [location] listInvert(location [int] list)
{
	boolean [location] result;
	foreach key in list
	{
		result[list[key]] = true;
	}
	return result;
}

boolean [item] listInvert(item [int] list)
{
	boolean [item] result;
	foreach key in list
	{
		result[list[key]] = true;
	}
	return result;
}

boolean [monster] listInvert(monster [int] list)
{
	boolean [monster] result;
	foreach key in list
	{
		result[list[key]] = true;
	}
	return result;
}

boolean [familiar] listInvert(familiar [int] list)
{
	boolean [familiar] result;
	foreach key in list
	{
		result[list[key]] = true;
	}
	return result;
}

int [int] listConvertToInt(string [int] list)
{
	int [int] result;
	foreach key in list
		result[key] = list[key].to_int();
	return result;
}

item [int] listConvertToItem(string [int] list)
{
	item [int] result;
	foreach key in list
		result[key] = list[key].to_item();
	return result;
}

string listFirstObject(string [int] list)
{
    foreach key in list
        return list[key];
    return "";
}

//(I'm assuming maps have a consistent enumeration order, which may not be the case)
int listKeyForIndex(string [int] list, int index)
{
	int i = 0;
	foreach key in list
	{
		if (i == index)
			return key;
		i += 1;
	}
	return -1;
}

int listKeyForIndex(location [int] list, int index)
{
	int i = 0;
	foreach key in list
	{
		if (i == index)
			return key;
		i += 1;
	}
	return -1;
}

int listKeyForIndex(familiar [int] list, int index)
{
	int i = 0;
	foreach key in list
	{
		if (i == index)
			return key;
		i += 1;
	}
	return -1;
}

int listKeyForIndex(item [int] list, int index)
{
	int i = 0;
	foreach key in list
	{
		if (i == index)
			return key;
		i += 1;
	}
	return -1;
}

int listKeyForIndex(monster [int] list, int index)
{
	int i = 0;
	foreach key in list
	{
		if (i == index)
			return key;
		i += 1;
	}
	return -1;
}

int llistKeyForIndex(string [int][int] list, int index)
{
	int i = 0;
	foreach key in list
	{
		if (i == index)
			return key;
		i += 1;
	}
	return -1;
}

string listGetRandomObject(string [int] list)
{
    if (list.count() == 0)
        return "";
    if (list.count() == 1)
    	return list[listKeyForIndex(list, 0)];
    return list[listKeyForIndex(list, random(list.count()))];
}

item listGetRandomObject(item [int] list)
{
    if (list.count() == 0)
        return $item[none];
    if (list.count() == 1)
    	return list[listKeyForIndex(list, 0)];
    return list[listKeyForIndex(list, random(list.count()))];
}

location listGetRandomObject(location [int] list)
{
    if (list.count() == 0)
        return $location[none];
    if (list.count() == 1)
    	return list[listKeyForIndex(list, 0)];
    return list[listKeyForIndex(list, random(list.count()))];
}

familiar listGetRandomObject(familiar [int] list)
{
    if (list.count() == 0)
        return $familiar[none];
    if (list.count() == 1)
    	return list[listKeyForIndex(list, 0)];
    return list[listKeyForIndex(list, random(list.count()))];
}

monster listGetRandomObject(monster [int] list)
{
    if (list.count() == 0)
        return $monster[none];
    if (list.count() == 1)
    	return list[listKeyForIndex(list, 0)];
    return list[listKeyForIndex(list, random(list.count()))];
}


boolean listContainsValue(monster [int] list, monster vo)
{
    foreach key, v2 in list
    {
        if (v2 == vo)
            return true;
    }
    return false;
}

string [int] listInvert(boolean [string] list)
{
    string [int] out;
    foreach m, value in list
    {
        if (value)
            out.listAppend(m);
    }
    return out;
}

int [int] listInvert(boolean [int] list)
{
    int [int] out;
    foreach m, value in list
    {
        if (value)
            out.listAppend(m);
    }
    return out;
}

skill [int] listInvert(boolean [skill] list)
{
    skill [int] out;
    foreach m, value in list
    {
        if (value)
            out.listAppend(m);
    }
    return out;
}

monster [int] listInvert(boolean [monster] monsters)
{
    monster [int] out;
    foreach m, value in monsters
    {
        if (value)
            out.listAppend(m);
    }
    return out;
}

location [int] listInvert(boolean [location] list)
{
    location [int] out;
    foreach k, value in list
    {
        if (value)
            out.listAppend(k);
    }
    return out;
}

familiar [int] listInvert(boolean [familiar] list)
{
    familiar [int] out;
    foreach k, value in list
    {
        if (value)
            out.listAppend(k);
    }
    return out;
}

item [int] listInvert(boolean [item] list)
{
    item [int] out;
    foreach k, value in list
    {
        if (value)
            out.listAppend(k);
    }
    return out;
}

skill [int] listConvertStringsToSkills(string [int] list)
{
    skill [int] out;
    foreach key, s in list
    {
        out.listAppend(s.to_skill());
    }
    return out;
}

monster [int] listConvertStringsToMonsters(string [int] list)
{
    monster [int] out;
    foreach key, s in list
    {
        out.listAppend(s.to_monster());
    }
    return out;
}

int [int] stringToIntIntList(string input, string delimiter)
{
	int [int] out;
	if (input == "")
		return out;
	foreach key, v in input.split_string(delimiter)
	{
		out.listAppend(v.to_int());
	}
	return out;
}

int [int] stringToIntIntList(string input)
{
	return stringToIntIntList(input, ",");
}



buffer to_buffer(string str)
{
	buffer result;
	result.append(str);
	return result;
}

buffer copyBuffer(buffer buf)
{
    buffer result;
    result.append(buf);
    return result;
}

//split_string returns an immutable array, which will error on certain edits
//Use this function - it converts to an editable map.
string [int] split_string_mutable(string source, string delimiter)
{
	string [int] result;
	string [int] immutable_array = split_string(source, delimiter);
	foreach key in immutable_array
		result[key] = immutable_array[key];
	return result;
}

//This returns [] for empty strings. This isn't standard for split(), but is more useful for passing around lists. Hacky, I suppose.
string [int] split_string_alternate(string source, string delimiter)
{
    if (source.length() == 0)
        return listMakeBlankString();
    return split_string_mutable(source, delimiter);
}

string slot_to_string(slot s)
{
    if (s == $slot[acc1] || s == $slot[acc2] || s == $slot[acc3])
        return "accessory";
    else if (s == $slot[sticker1] || s == $slot[sticker2] || s == $slot[sticker3])
        return "sticker";
    else if (s == $slot[folder1] || s == $slot[folder2] || s == $slot[folder3] || s == $slot[folder4] || s == $slot[folder5])
        return "folder";
    else if (s == $slot[fakehand])
        return "fake hand";
    else if (s == $slot[crown-of-thrones])
        return "crown of thrones";
    else if (s == $slot[buddy-bjorn])
        return "buddy bjorn";
    return s;
}

string slot_to_plural_string(slot s)
{
    if (s == $slot[acc1] || s == $slot[acc2] || s == $slot[acc3])
        return "accessories";
    else if (s == $slot[hat])
        return "hats";
    else if (s == $slot[weapon])
        return "weapons";
    else if (s == $slot[off-hand])
        return "off-hands";
    else if (s == $slot[shirt])
        return "shirts";
    else if (s == $slot[back])
        return "back items";
    
    return s.slot_to_string();
}


string format_today_to_string(string desired_format)
{
    return format_date_time("yyyyMMdd", today_to_string(), desired_format);
}


string [int] __int_to_wordy_map;
string int_to_wordy(int v) //Not complete, only supports a handful:
{
    if (__int_to_wordy_map.count() == 0)
    {
        __int_to_wordy_map = split_string("zero,one,two,three,four,five,six,seven,eight,nine,ten,eleven,twelve,thirteen,fourteen,fifteen,sixteen,seventeen,eighteen,nineteen,twenty,twenty-one,twenty-two,twenty-three,twenty-four,twenty-five,twenty-six,twenty-seven,twenty-eight,twenty-nine,thirty,thirty-one", ",");
    }
    if (__int_to_wordy_map contains v)
        return __int_to_wordy_map[v];
    return v.to_string();
}


boolean stringHasPrefix(string s, string prefix)
{
	if (s.length() < prefix.length())
		return false;
	else if (s.length() == prefix.length())
		return (s == prefix);
	else if (substring(s, 0, prefix.length()) == prefix)
		return true;
	return false;
}

boolean stringHasSuffix(string s, string suffix)
{
	if (s.length() < suffix.length())
		return false;
	else if (s.length() == suffix.length())
		return (s == suffix);
	else if (substring(s, s.length() - suffix.length()) == suffix)
		return true;
	return false;
}

string capitaliseFirstLetter(string v)
{
	buffer buf = v.to_buffer();
	if (v.length() <= 0)
		return v;
	buf.replace(0, 1, buf.char_at(0).to_upper_case());
	return buf.to_string();
}

string pluralise(float value, string non_plural, string plural)
{
	if (value == 1.0)
		return value + " " + non_plural;
	else
		return value + " " + plural;
}

string pluralise(int value, string non_plural, string plural)
{
	if (value == 1)
		return value + " " + non_plural;
	else
		return value + " " + plural;
}

string pluralise(int value, item i)
{
	return pluralise(value, i.to_string(), i.plural);
}

string pluralise(item i) //whatever we have around
{
	return pluralise(i.available_amount(), i);
}

string pluralise(effect e)
{
    return pluralise(e.have_effect(), "turn", "turns") + " of " + e;
}

string pluraliseWordy(int value, string non_plural, string plural)
{
	if (value == 1)
    {
        if (non_plural == "more time") //we're gonna celebrate
            return "One More Time";
        else if (non_plural == "more turn")
            return "One More Turn";
		return value.int_to_wordy() + " " + non_plural;
    }
	else
		return value.int_to_wordy() + " " + plural;
}

string pluraliseWordy(int value, item i)
{
	return pluraliseWordy(value, i.to_string(), i.plural);
}

string pluraliseWordy(item i) //whatever we have around
{
	return pluraliseWordy(i.available_amount(), i);
}


//Additions to standard API:
//Auto-conversion property functions:
boolean get_property_boolean(string property)
{
	return get_property(property).to_boolean();
}

int get_property_int(string property)
{
	return get_property(property).to_int_silent();
}

location get_property_location(string property)
{
	return get_property(property).to_location();
}

float get_property_float(string property)
{
	return get_property(property).to_float();
}

monster get_property_monster(string property)
{
	return get_property(property).to_monster();
}

//Returns true if the propery is equal to my_ascensions(). Commonly used in mafia properties.
boolean get_property_ascension(string property)
{
    return get_property_int(property) == my_ascensions();
}

element get_property_element(string property)
{
    return get_property(property).to_element();
}

item get_property_item(string property)
{
    return get_property(property).to_item();
}


/*
Discovery - get_ingredients() takes up to 5.8ms per call, scaling to inventory size. Fixing the code in mafia might be possible, but it's old and looks complicated.
This implementation is not 1:1 compatible, as it doesn't take into account your current status, but we don't generally need that information(?).
*/

//Relevant prototype:
//int [item] get_ingredients_fast(item it)


static
{
    int [item][item] __item_ingredients;
    boolean [item] __item_is_purchasable_from_a_store;
}



boolean parseDatafileItem(int [item] out, string item_name)
{
    if (item_name == "") return false;
    
    item it = item_name.to_item();
    if (it != $item[none])
    {
        out[it] += 1;
    }
    else if (item_name.contains_text("("))
    {
        //Do complicated parsing.
        //NOTE: "CRIMBCO Employee Handbook (chapter 1)" and "snow berries (7)" are both valid entries that mean different things.
        string [int][int] matches = item_name.group_string("(.*?) \\(([0-9]*)\\)");
        if (matches[0].count() == 3)
        {
            it = matches[0][1].to_item();
            int amount = matches[0][2].to_int();
            if (it != $item[none] && amount > 0)
            {
                out[it] += amount;
            }
        }
    }
    return true;
}


Record ConcoctionMapEntry
{
    //Only way I know how to parse this file with file_to_map. string [int] won't work, string [string] won't...
    string craft_type;
    string mixing_item_1;
    string mixing_item_2;
    string mixing_item_3;
    string mixing_item_4;
    string mixing_item_5;
    string mixing_item_6;
    string mixing_item_7;
    string mixing_item_8;
    string mixing_item_9;
    string mixing_item_10;
    string mixing_item_11;
    string mixing_item_12;
    string mixing_item_13;
    string mixing_item_14;
    string mixing_item_15;
    string mixing_item_16;
    string mixing_item_17;
    string mixing_item_18;
};

void parseConcoction(int [item] ingredients, ConcoctionMapEntry c)
{
    //If this ever shows up somewhere, please understand, it's not my fault file_to_map works this way.
    if (!parseDatafileItem(ingredients, c.mixing_item_1))
        return;
    if (!parseDatafileItem(ingredients, c.mixing_item_2))
        return;
    if (!parseDatafileItem(ingredients, c.mixing_item_3))
        return;
    if (!parseDatafileItem(ingredients, c.mixing_item_4))
        return;
    if (!parseDatafileItem(ingredients, c.mixing_item_5))
        return;
    if (!parseDatafileItem(ingredients, c.mixing_item_6))
        return;
    if (!parseDatafileItem(ingredients, c.mixing_item_7))
        return;
    if (!parseDatafileItem(ingredients, c.mixing_item_8))
        return;
    if (!parseDatafileItem(ingredients, c.mixing_item_9))
        return;
    if (!parseDatafileItem(ingredients, c.mixing_item_10))
        return;
    if (!parseDatafileItem(ingredients, c.mixing_item_11))
        return;
    if (!parseDatafileItem(ingredients, c.mixing_item_12))
        return;
    if (!parseDatafileItem(ingredients, c.mixing_item_13))
        return;
    if (!parseDatafileItem(ingredients, c.mixing_item_14))
        return;
    if (!parseDatafileItem(ingredients, c.mixing_item_15))
        return;
    if (!parseDatafileItem(ingredients, c.mixing_item_16))
        return;
    if (!parseDatafileItem(ingredients, c.mixing_item_17))
        return;
    if (!parseDatafileItem(ingredients, c.mixing_item_18))
        return;
}

void initialiseItemIngredients()
{
    if (__item_ingredients.count() > 0) return;
    
    //Parse concoctions:
    //Highest observed so far: 17.
    if (true)
    {
        string [string, string, string, string, string, string, string, string, string, string, string, string, string, string, string, string, string, string, string] concoctions_map_2;
        file_to_map("data/concoctions.txt", concoctions_map_2);
        foreach crafting_thing, crafting_type, mixing_item_1, mixing_item_2, mixing_item_3, mixing_item_4, mixing_item_5, mixing_item_6, mixing_item_7, mixing_item_8, mixing_item_9, mixing_item_10, mixing_item_11, mixing_item_12, mixing_item_13, mixing_item_14, mixing_item_15, mixing_item_16, mixing_item_17, mixing_item_18 in concoctions_map_2
        {
            if (crafting_type == "SUSHI" || crafting_type == "VYKEA") continue; //not really items
            if (crafting_type == "CLIPART") continue; //bucket of wine is not made of three turtle totems
            item it = crafting_thing.to_item();
            if (it == $item[none])
            {
                int [item] item_results;
                parseDatafileItem(item_results, crafting_thing);
                if (item_results.count() == 0)
                {
                    //print_html("Unknown crafting_thing " + crafting_thing);
                    continue;
                }
                foreach it2 in item_results
                    it = it2;
            }
            if (crafting_type.contains_text("ROW"))
                __item_is_purchasable_from_a_store[it] = true;
            if (__item_ingredients contains it) continue; //mafia uses first defined entry
            
            int [item] ingredients;
            //Create map entry:
            ConcoctionMapEntry c;
            c.craft_type = crafting_type;
            c.mixing_item_1 = mixing_item_1;
            c.mixing_item_2 = mixing_item_2;
            c.mixing_item_3 = mixing_item_3;
            c.mixing_item_4 = mixing_item_4;
            c.mixing_item_5 = mixing_item_5;
            c.mixing_item_6 = mixing_item_6;
            c.mixing_item_7 = mixing_item_7;
            c.mixing_item_8 = mixing_item_8;
            c.mixing_item_9 = mixing_item_9;
            c.mixing_item_10 = mixing_item_10;
            c.mixing_item_11 = mixing_item_11;
            c.mixing_item_12 = mixing_item_12;
            c.mixing_item_13 = mixing_item_13;
            c.mixing_item_14 = mixing_item_14;
            c.mixing_item_15 = mixing_item_15;
            c.mixing_item_16 = mixing_item_16;
            c.mixing_item_17 = mixing_item_17;
            c.mixing_item_18 = mixing_item_18;
            
            parseConcoction(ingredients, c);
            
            if (ingredients.count() > 0)
                __item_ingredients[it] = ingredients;
        }
    }
    else
    {
        //Not compatible.
        //Concoction manager seems to read the first entry, not the second. file_to_map reads the second. Example: spooky wad.
        //Or maybe it's just random which the concoction manager uses? Example: bloody beer vs. spooky wad. Or it picks the one we can make...?
        ConcoctionMapEntry [string] concoctions_map;
        file_to_map("data/concoctions.txt", concoctions_map);
        foreach crafting_thing in concoctions_map
        {
            ConcoctionMapEntry c = concoctions_map[crafting_thing];
            item it = crafting_thing.to_item();
            if (it == $item[none])
                continue;
            
            int [item] ingredients;
            
            parseConcoction(ingredients, c);
            
            if (__item_ingredients contains it) continue; //mafia uses first defined entry
            if (ingredients.count() > 0)
                __item_ingredients[it] = ingredients;
        }
    }
    //Parse coinmasters:
    
    /*Record CoinmastersMapEntry
    {
        string buy_or_sell_type;
        int amount;
        item it;
        string row_id;
    };
    CoinmastersMapEntry [string] coinmasters_map;*/
    string [string,string,int,string] coinmasters_map;
    file_to_map("data/coinmasters.txt", coinmasters_map);
    //print_html("coinmasters_map = " + coinmasters_map.to_json());
    foreach master_name, type, amount, item_string in coinmasters_map
    {
        //FIXME track if coinmaster is accessible?
        //print_html(master_name + ", " + type + ", " + amount + ", " + item_string);
        if (type != "buy") continue;
        coinmaster c = master_name.to_coinmaster();
        if (c == $coinmaster[none])
        {
            //Hmm....
            //print_html(master_name + " is not a coinmaster");
            continue;
        }
        if (c.item == $item[none]) //bat-fabricator
            continue;
        item it = item_string.to_item();
        if (it == $item[none])
        {
            //peppermint tailings (10) at the moment
            //FIXME write this
            continue;
        }
        
        if (it == $item[none])
            continue;
        
        __item_is_purchasable_from_a_store[it] = true;
        if (__item_ingredients contains it) continue;
        
        int [item] ingredients;
        ingredients[c.item] = amount;
        __item_ingredients[it] = ingredients;
    }
    
}


int [item] get_ingredients_fast(item it)
{
    //return it.get_ingredients();
    if (__item_ingredients.count() == 0)
        initialiseItemIngredients();
    if (!(__item_ingredients contains it))
    {
        //This is six milliseconds per call, but only if the item has an ingredient(?), so be wary:
        int [item] ground_truth = it.get_ingredients();
        if (ground_truth.count() > 0) //We could cache it if it's empty, except sometimes that changes.
            __item_ingredients[it] = ground_truth;
    }
    return __item_ingredients[it];
}

boolean item_is_purchasable_from_a_store(item it)
{
    return __item_is_purchasable_from_a_store[it];
}

boolean item_cannot_be_asdon_martined_because_it_was_purchased_from_a_store(item it)
{
	if ($items[wasabi pocky,tobiko pocky,natto pocky,wasabi-infused sake,tobiko-infused sake,natto-infused sake] contains it) return false;
	return it.item_is_purchasable_from_a_store();
}

void testItemIngredients()
{
    initialiseItemIngredients();
    print_html(__item_ingredients.count() + " ingredients known.");
    foreach it in $items[]
    {
        int [item] ground_truth_ingredients = it.get_ingredients();
        int [item] our_ingredients = get_ingredients_fast(it);
        if (ground_truth_ingredients.count() == 0 && our_ingredients.count() == 0) continue;
        
        boolean passes = true;
        if (ground_truth_ingredients.count() != our_ingredients.count())
        {
            passes = false;
            if (ground_truth_ingredients.count() == 0 && our_ingredients.count() > 0) //probably just a coinmaster
                continue;
        }
        else
        {
            foreach it2, amount in ground_truth_ingredients
            {
                if (our_ingredients[it2] != amount)
                {
                    passes = false;
                    break;
                }
            }
        }
        if (!passes)
        {
            print_html(it + ": " + ground_truth_ingredients.to_json() + " vs " + our_ingredients.to_json());
        }
    }
}

/*void main()
{
    testItemIngredients();
}*/



static
{
    int PATH_UNKNOWN = -1;
    int PATH_NONE = 0;
    int PATH_BOOZETAFARIAN = 1;
    int PATH_TEETOTALER = 2;
    int PATH_OXYGENARIAN = 3;

    int PATH_BEES_HATE_YOU = 4;
    int PATH_WAY_OF_THE_SURPRISING_FIST = 6;
    int PATH_TRENDY = 7;
    int PATH_AVATAR_OF_BORIS = 8;
    int PATH_BUGBEAR_INVASION = 9;
    int PATH_ZOMBIE_SLAYER = 10;
    int PATH_CLASS_ACT = 11;
    int PATH_AVATAR_OF_JARLSBERG = 12;
    int PATH_BIG = 14;
    int PATH_KOLHS = 15;
    int PATH_CLASS_ACT_2 = 16;
    int PATH_AVATAR_OF_SNEAKY_PETE = 17;
    int PATH_SLOW_AND_STEADY = 18;
    int PATH_HEAVY_RAINS = 19;
    int PATH_PICKY = 21;
    int PATH_STANDARD = 22;
    int PATH_ACTUALLY_ED_THE_UNDYING = 23;
    int PATH_ONE_CRAZY_RANDOM_SUMMER = 24;
    int PATH_COMMUNITY_SERVICE = 25;
    int PATH_AVATAR_OF_WEST_OF_LOATHING = 26;
    int PATH_THE_SOURCE = 27;
    int PATH_NUCLEAR_AUTUMN = 28;
    int PATH_GELATINOUS_NOOB = 29;
    int PATH_LICENSE_TO_ADVENTURE = 30;
    int PATH_LIVE_ASCEND_REPEAT = 31;
    int PATH_POCKET_FAMILIARS = 32;
    int PATH_G_LOVER = 33;
}

int __my_path_id_cached = -11;
int my_path_id()
{
    if (__my_path_id_cached != -11)
        return __my_path_id_cached;
    string path_name = my_path();
    
    if (path_name == "" || path_name == "None")
        __my_path_id_cached = PATH_NONE;
    else if (path_name == "Teetotaler")
        __my_path_id_cached = PATH_TEETOTALER;
    else if (path_name == "Boozetafarian")
        __my_path_id_cached = PATH_BOOZETAFARIAN;
    else if (path_name == "Oxygenarian")
        __my_path_id_cached = PATH_OXYGENARIAN;
    else if (path_name == "Bees Hate You")
        __my_path_id_cached = PATH_BEES_HATE_YOU;
    else if (path_name == "Way of the Surprising Fist")
        __my_path_id_cached = PATH_WAY_OF_THE_SURPRISING_FIST;
    else if (path_name == "Trendy")
        __my_path_id_cached = PATH_TRENDY;
    else if (path_name == "Avatar of Boris")
        __my_path_id_cached = PATH_AVATAR_OF_BORIS;
    else if (path_name == "Bugbear Invasion")
        __my_path_id_cached = PATH_BUGBEAR_INVASION;
    else if (path_name == "Zombie Slayer")
        __my_path_id_cached = PATH_ZOMBIE_SLAYER;
    else if (path_name == "Class Act")
        __my_path_id_cached = PATH_CLASS_ACT;
    else if (path_name == "Avatar of Jarlsberg")
        __my_path_id_cached = PATH_AVATAR_OF_JARLSBERG;
    else if (path_name == "BIG!")
        __my_path_id_cached = PATH_BIG;
    else if (path_name == "KOLHS")
        __my_path_id_cached = PATH_KOLHS;
    else if (path_name == "Class Act II: A Class For Pigs")
        __my_path_id_cached = PATH_CLASS_ACT_2;
    else if (path_name == "Avatar of Sneaky Pete")
        __my_path_id_cached = PATH_AVATAR_OF_SNEAKY_PETE;
    else if (path_name == "Slow and Steady")
        __my_path_id_cached = PATH_SLOW_AND_STEADY;
    else if (path_name == "Heavy Rains")
        __my_path_id_cached = PATH_HEAVY_RAINS;
    else if (path_name == "Picky")
        __my_path_id_cached = PATH_PICKY;
    else if (path_name == "Standard")
        __my_path_id_cached = PATH_STANDARD;
    else if (path_name == "Actually Ed the Undying")
        __my_path_id_cached = PATH_ACTUALLY_ED_THE_UNDYING;
    else if (path_name == "One Crazy Random Summer")
        __my_path_id_cached = PATH_ONE_CRAZY_RANDOM_SUMMER;
    else if (path_name == "Community Service" || path_name == "25")
        __my_path_id_cached = PATH_COMMUNITY_SERVICE;
    else if (path_name == "Avatar of West of Loathing")
        __my_path_id_cached = PATH_AVATAR_OF_WEST_OF_LOATHING;
    else if (path_name == "The Source")
        __my_path_id_cached = PATH_THE_SOURCE;
    else if (path_name == "Nuclear Autumn" || path_name == "28")
        __my_path_id_cached = PATH_NUCLEAR_AUTUMN;
    else if (path_name == "Gelatinous Noob")
        __my_path_id_cached = PATH_GELATINOUS_NOOB;
    else if (path_name == "License to Adventure")
        __my_path_id_cached = PATH_LICENSE_TO_ADVENTURE;
    else if (path_name == "Live. Ascend. Repeat.")
        __my_path_id_cached = PATH_LIVE_ASCEND_REPEAT;
    else if (path_name == "Pocket Familiars" || path_name == "32")
        __my_path_id_cached = PATH_POCKET_FAMILIARS;
    else if (path_name == "G-Lover" || path_name == "33")
        __my_path_id_cached = PATH_G_LOVER;
    else
        __my_path_id_cached = PATH_UNKNOWN;
    return __my_path_id_cached;
}

float numeric_modifier_replacement(item it, string modifier)
{
    string modifier_lowercase = modifier.to_lower_case();
    float additional = 0;
    if (my_path_id() == PATH_G_LOVER && !it.contains_text("g") && !it.contains_text("G"))
    	return 0.0;
    if (it == $item[your cowboy boots])
    {
        if (modifier_lowercase == "monster level" && $slot[bootskin].equipped_item() == $item[diamondback skin])
        {
            return 20.0;
        }
        if (modifier_lowercase == "initiative" && $slot[bootspur].equipped_item() == $item[quicksilver spurs])
            return 30;
        if (modifier_lowercase == "item drop" && $slot[bootspur].equipped_item() == $item[nicksilver spurs])
            return 30;
        if (modifier_lowercase == "muscle percent" && $slot[bootskin].equipped_item() == $item[grizzled bearskin])
            return 50.0;
        if (modifier_lowercase == "mysticality percent" && $slot[bootskin].equipped_item() == $item[frontwinder skin])
            return 50.0;
        if (modifier_lowercase == "moxie percent" && $slot[bootskin].equipped_item() == $item[mountain lion skin])
            return 50.0;
        //FIXME deal with rest (resistance, etc)
    }
    //so, when we don't have the smithsness items equipped, they have a numeric modifier of zero.
    //but, they always have an inherent value of five. so give them that.
    //FIXME do other smithsness items
    if (it == $item[a light that never goes out] && modifier_lowercase == "item drop")
    {
    	if (it.equipped_amount() == 0)
     	   additional += 5;
    }
    return numeric_modifier(it, modifier) + additional;
}


static
{
    skill [class][int] __skills_by_class;
    
    void initialiseSkillsByClass()
    {
        if (__skills_by_class.count() > 0) return;
        foreach s in $skills[]
        {
            if (s.class != $class[none])
            {
                if (!(__skills_by_class contains s.class))
                {
                    skill [int] blank;
                    __skills_by_class[s.class] = blank;
                }
                __skills_by_class[s.class].listAppend(s);
            }
        }
    }
    initialiseSkillsByClass();
}


static
{
    boolean [skill] __libram_skills;
    
    void initialiseLibramSkills()
    {
        foreach s in $skills[]
        {
            if (s.libram)
                __libram_skills[s] = true;
        }
    }
    initialiseLibramSkills();
}


static
{
    boolean [item] __items_that_craft_food;
    boolean [item] __minus_combat_equipment;
    boolean [item] __equipment;
    boolean [item] __items_in_outfits;
    boolean [string][item] __equipment_by_numeric_modifier;
    void initialiseItems()
    {
        foreach it in $items[]
        {
            //Crafting:
            string craft_type = it.craft_type();
            if (craft_type.contains_text("Cooking"))
            {
                foreach ingredient in it.get_ingredients_fast()
                {
                    __items_that_craft_food[ingredient] = true;
                }
            }
            
            //Equipment:
            if (it.to_slot() != $slot[none])
            {
                __equipment[it] = true;
                if (it.numeric_modifier("combat rate") < 0)
                    __minus_combat_equipment[it] = true;
            }
        }
        foreach key, outfit_name in all_normal_outfits()
        {
            foreach key, it in outfit_pieces(outfit_name)
                __items_in_outfits[it] = true;
        }
    }
    initialiseItems();
}

boolean [item] equipmentWithNumericModifier(string modifier)
{
	modifier = modifier.to_lower_case();
    boolean [item] dynamic_items;
    dynamic_items[to_item("kremlin's greatest briefcase")] = true;
    dynamic_items[$item[your cowboy boots]] = true;
    dynamic_items[$item[a light that never goes out]] = true; //FIXME all smithsness items
    if (!(__equipment_by_numeric_modifier contains modifier))
    {
        //Build it:
        boolean [item] blank;
        __equipment_by_numeric_modifier[modifier] = blank;
        foreach it in __equipment
        {
            if (dynamic_items contains it) continue;
            if (it.numeric_modifier(modifier) != 0.0)
                __equipment_by_numeric_modifier[modifier][it] = true;
        }
    }
    //Certain equipment is dynamic. Inspect them dynamically:
    boolean [item] extra_results;
    foreach it in dynamic_items
    {
        if (it.numeric_modifier_replacement(modifier) != 0.0)
        {
            extra_results[it] = true;
        }
    }
    //damage + spell damage is basically the same for most things
    string secondary_modifier = "";
    foreach e in $elements[hot,cold,spooky,stench,sleaze]
    {
        if (modifier == e + " damage")
            secondary_modifier = e + " spell damage";
    }
    if (secondary_modifier != "")
    {
    	foreach it in equipmentWithNumericModifier(secondary_modifier)
        	extra_results[it] = true;
    }
    
    if (extra_results.count() == 0)
        return __equipment_by_numeric_modifier[modifier];
    else
    {
        //Add extras:
        foreach it in __equipment_by_numeric_modifier[modifier]
        {
            extra_results[it] = true;
        }
        return extra_results;
    }
}

static
{
    boolean [item] __beancannon_source_items = $items[Heimz Fortified Kidney Beans,Hellfire Spicy Beans,Mixed Garbanzos and Chickpeas,Pork 'n' Pork 'n' Pork 'n' Beans,Shrub's Premium Baked Beans,Tesla's Electroplated Beans,Frigid Northern Beans,Trader Olaf's Exotic Stinkbeans,World's Blackest-Eyed Peas];
}

static
{
    //This would be a good mafia proxy value. Feature request?
    boolean [skill] __combat_skills_that_are_spells;
    void initialiseCombatSkillsThatAreSpells()
    {
    	//Saucecicle,Surge of Icing are guesses
        foreach s in $skills[Awesome Balls of Fire,Bake,Blend,Blinding Flash,Boil,Candyblast,Cannelloni Cannon,Carbohydrate Cudgel,Chop,CLEESH,Conjure Relaxing Campfire,Creepy Lullaby,Curdle,Doubt Shackles,Eggsplosion,Fear Vapor,Fearful Fettucini,Freeze,Fry,Grease Lightning,Grill,Haggis Kick,Inappropriate Backrub,K&auml;seso&szlig;esturm,Mudbath,Noodles of Fire,Rage Flame,Raise Backup Dancer,Ravioli Shurikens,Salsaball,Saucegeyser,Saucemageddon,Saucestorm,Saucy Salve,Shrap,Slice,Snowclone,Spaghetti Spear,Stream of Sauce,Stringozzi Serpent,Stuffed Mortar Shell,Tear Wave,Toynado,Volcanometeor Showeruption,Wassail,Wave of Sauce,Weapon of the Pastalord,Saucecicle,Surge of Icing]
        {
            __combat_skills_that_are_spells[s] = true;
        }
        foreach s in $skills[Lavafava,Pungent Mung,Beanstorm] //FIXME cowcall? snakewhip?
            __combat_skills_that_are_spells[s] = true;
    }
    initialiseCombatSkillsThatAreSpells();
}

static
{
    boolean [monster] __snakes;
    void initialiseSnakes()
    {
        __snakes = $monsters[aggressive grass snake,Bacon snake,Batsnake,Black adder,Burning Snake of Fire,Coal snake,Diamondback rattler,Frontwinder,Frozen Solid Snake,King snake,Licorice snake,Mutant rattlesnake,Prince snake,Sewer snake with a sewer snake in it,Snakeleton,The Snake With Like Ten Heads,Tomb asp,Trouser Snake,Whitesnake];
    }
    initialiseSnakes();
}

item lookupAWOLOilForMonster(monster m)
{
    if (__snakes contains m)
        return $item[snake oil];
    else if ($phylums[beast,dude,hippy,humanoid,orc,pirate] contains m.phylum)
        return $item[skin oil];
    else if ($phylums[bug,construct,constellation,demon,elemental,elf,fish,goblin,hobo,horror,mer-kin,penguin,plant,slime,weird] contains m.phylum)
        return $item[unusual oil];
    else if ($phylums[undead] contains m.phylum)
        return $item[eldritch oil];
    return $item[none];
}

static
{
    monster [location] __protonic_monster_for_location {$location[Cobb's Knob Treasury]:$monster[The ghost of Ebenoozer Screege], $location[The Haunted Conservatory]:$monster[The ghost of Lord Montague Spookyraven], $location[The Haunted Gallery]:$monster[The ghost of Waldo the Carpathian], $location[The Haunted Kitchen]:$monster[The Icewoman], $location[The Haunted Wine Cellar]:$monster[The ghost of Jim Unfortunato], $location[The Icy Peak]:$monster[the ghost of Sam McGee], $location[Inside the Palindome]:$monster[Emily Koops, a spooky lime], $location[Madness Bakery]:$monster[the ghost of Monsieur Baguelle], $location[The Old Landfill]:$monster[the ghost of Vanillica "Trashblossom" Gorton], $location[The Overgrown Lot]:$monster[the ghost of Oily McBindle], $location[The Skeleton Store]:$monster[boneless blobghost], $location[The Smut Orc Logging Camp]:$monster[The ghost of Richard Cockingham], $location[The Spooky Forest]:$monster[The Headless Horseman]};
}

boolean mafiaIsPastRevision(int revision_number)
{
    if (get_revision() <= 0) //get_revision reports zero in certain cases; assume they're on a recent version
        return true;
    return (get_revision() >= revision_number);
}


boolean have_familiar_replacement(familiar f)
{
    //have_familiar bugs in avatar of sneaky pete for now, so:
    if (my_path_id() == PATH_AVATAR_OF_BORIS || my_path_id() == PATH_AVATAR_OF_JARLSBERG || my_path_id() == PATH_AVATAR_OF_SNEAKY_PETE)
        return false;
    return f.have_familiar();
}

//Similar to have_familiar, except it also checks trendy (not sure if have_familiar supports trendy) and 100% familiar runs
boolean familiar_is_usable(familiar f)
{
    //r13998 has most of these
    if (my_path_id() == PATH_AVATAR_OF_BORIS || my_path_id() == PATH_AVATAR_OF_JARLSBERG || my_path_id() == PATH_AVATAR_OF_SNEAKY_PETE || my_path_id() == PATH_ACTUALLY_ED_THE_UNDYING || my_path_id() == PATH_LICENSE_TO_ADVENTURE || my_path_id() == PATH_POCKET_FAMILIARS)
        return false;
    if (!is_unrestricted(f))
        return false;
    if (my_path_id() == PATH_G_LOVER && !f.contains_text("g") && !f.contains_text("G"))
        return false;
	int single_familiar_run = get_property_int("singleFamiliarRun");
	if (single_familiar_run != -1 && my_turncount() >= 30) //after 30 turns, they're probably sure
	{
		if (f == single_familiar_run.to_familiar())
			return true;
		return false;
	}
	if (my_path_id() == PATH_TRENDY)
	{
		if (!is_trendy(f))
			return false;
	}
	else if (my_path_id() == PATH_BEES_HATE_YOU)
	{
		if (f.to_string().contains_text("b") || f.to_string().contains_text("B")) //bzzzz!
			return false; //so not green
	}
	return have_familiar(f);
}

//inigo's used to show up as have_skill while under restrictions, possibly others
boolean skill_is_usable(skill s)
{
    if (!s.have_skill())
        return false;
    if (!s.is_unrestricted())
        return false;
    if (my_path_id() == PATH_G_LOVER && (!s.passive || s == $skill[meteor lore]) && !s.contains_text("g") && !s.contains_text("G"))
    	return false;
    if ($skills[rapid prototyping] contains s)
        return $item[hand turkey outline].is_unrestricted();
    return true;
}

boolean a_skill_is_usable(boolean [skill] skills)
{
	foreach s in skills
	{
		if (s.skill_is_usable()) return true;
	}
	return false;
}

boolean item_is_usable(item it)
{
    if (!it.is_unrestricted())
        return false;
    if (my_path_id() == PATH_G_LOVER && !it.contains_text("g") && !it.contains_text("G"))
        return false;
    if (my_path_id() == PATH_BEES_HATE_YOU && (it.contains_text("b") || it.contains_text("B")))
    	return false;
	return true;
}

boolean effect_is_usable(effect e)
{
    if (my_path_id() == PATH_G_LOVER && !e.contains_text("g") && !e.contains_text("G"))
        return false;
    return true;
}

boolean in_ronin()
{
	return !can_interact();
}


boolean [item] makeConstantItemArrayMutable(boolean [item] array)
{
    boolean [item] result;
    foreach k in array
        result[k] = array[k];
    
    return result;
}

boolean [location] makeConstantLocationArrayMutable(boolean [location] locations)
{
    boolean [location] result;
    foreach k in locations
        result[k] = locations[k];
    
    return result;
}

boolean [skill] makeConstantSkillArrayMutable(boolean [skill] array)
{
    boolean [skill] result;
    foreach k in array
        result[k] = array[k];
    
    return result;
}

boolean [effect] makeConstantEffectArrayMutable(boolean [effect] array)
{
    boolean [effect] result;
    foreach k in array
        result[k] = array[k];
    
    return result;
}

//Same as my_primestat(), except refers to substat
stat my_primesubstat()
{
	if (my_primestat() == $stat[muscle])
		return $stat[submuscle];
	else if (my_primestat() == $stat[mysticality])
		return $stat[submysticality];
	else if (my_primestat() == $stat[moxie])
		return $stat[submoxie];
	return $stat[none];
}

item [int] items_missing(boolean [item] items)
{
    item [int] result;
    foreach it in items
    {
        if (it.available_amount() == 0)
            result.listAppend(it);
    }
    return result;
}

skill [int] skills_missing(boolean [skill] skills)
{
    skill [int] result;
    foreach s in skills
    {
        if (!s.have_skill())
            result.listAppend(s);
    }
    return result;
}

int storage_amount(boolean [item] items)
{
    int count = 0;
    foreach it in items
    {
        count += it.storage_amount();
    }
    return count;
}

int available_amount(boolean [item] items)
{
    //Usage:
    //$items[disco ball, corrupted stardust].available_amount()
    //Returns the total number of all items.
    int count = 0;
    foreach it in items
    {
        count += it.available_amount();
    }
    return count;
}

int creatable_amount(boolean [item] items)
{
    //Usage:
    //$items[disco ball, corrupted stardust].available_amount()
    //Returns the total number of all items.
    int count = 0;
    foreach it in items
    {
        count += it.creatable_amount();
    }
    return count;
}

int item_amount(boolean [item] items)
{
    int count = 0;
    foreach it in items
    {
        count += it.item_amount();
    }
    return count;
}

int have_effect(boolean [effect] effects)
{
    int count = 0;
    foreach e in effects
        count += e.have_effect();
    return count;
}

int available_amount(item [int] items)
{
    int count = 0;
    foreach key in items
    {
        count += items[key].available_amount();
    }
    return count;
}

int available_amount_ignoring_storage(item it)
{
    if (!in_ronin())
        return it.available_amount() - it.storage_amount();
    else
        return it.available_amount();
}

int available_amount_ignoring_closet(item it)
{
    if (get_property_boolean("autoSatisfyWithCloset"))
        return it.available_amount() - it.closet_amount();
    else
        return it.available_amount();
}

int available_amount_including_closet(item it)
{
    if (get_property_boolean("autoSatisfyWithCloset"))
        return it.available_amount();
    else
        return it.available_amount() + it.closet_amount();
}

//Display case, etc
//WARNING: Does not take into account your shop. Conceptually, the shop is things you're getting rid of... and they might be gone already.
int item_amount_almost_everywhere(item it)
{
    return it.closet_amount() + it.display_amount() + it.equipped_amount() + it.item_amount() + it.storage_amount();
}

//Similar to item_amount_almost_everywhere, but won't trigger a display case load unless it has to:
boolean haveAtLeastXOfItemEverywhere(item it, int amount)
{
    int total = 0;
    total += it.item_amount();
    if (total >= amount) return true;
    total += it.equipped_amount();
    if (total >= amount) return true;
    total += it.closet_amount();
    if (total >= amount) return true;
    total += it.storage_amount();
    if (total >= amount) return true;
    total += it.display_amount();
    if (total >= amount) return true;
    
    return false;
}

int equipped_amount(boolean [item] items)
{
    int count = 0;
    foreach it in items
    {
        count += it.equipped_amount();
    }
    return count;
}

int [item] creatable_items(boolean [item] items)
{
    int [item] creatable_items;
    foreach it in items
    {
        if (it.creatable_amount() == 0)
            continue;
        creatable_items[it] = it.creatable_amount();
    }
    return creatable_items;
}


item [slot] equipped_items()
{
    item [slot] result;
    foreach s in $slots[]
    {
        item it = s.equipped_item();
        if (it == $item[none])
            continue;
        result[s] = it;
    }
    return result;
}

//Have at least one of these familiars:
boolean have_familiar_replacement(boolean [familiar] familiars)
{
    foreach f in familiars
    {
        if (f.have_familiar())
            return true;
    }
    return false;
}

item [int] missing_outfit_components(string outfit_name)
{
    item [int] outfit_pieces = outfit_pieces(outfit_name);
    item [int] missing_components;
    foreach key in outfit_pieces
    {
        item it = outfit_pieces[key];
        if (it.available_amount() == 0)
            missing_components.listAppend(it);
    }
    return missing_components;
}


//have_outfit() will tell you if you have an outfit, but only if you pass stat checks. This does not stat check:
boolean have_outfit_components(string outfit_name)
{
    return (outfit_name.missing_outfit_components().count() == 0);
}

//Non-API-related functions:

boolean playerIsLoggedIn()
{
    return !(my_hash().length() == 0 || my_id() == 0);
}

int substatsForLevel(int level)
{
	if (level == 1)
		return 0;
	return pow2i(pow2i(level - 1) + 4);
}

int availableFullness()
{
	return fullness_limit() - my_fullness();
}

int availableDrunkenness()
{
    if (inebriety_limit() == 0) return 0; //certain edge cases
	return inebriety_limit() - my_inebriety();
}

int availableSpleen()
{
	return spleen_limit() - my_spleen_use();
}

item [int] missingComponentsToMakeItemPrivateImplementation(item it, int it_amounted_needed, int recursion_limit_remaining)
{
	item [int] result;
    if (recursion_limit_remaining <= 0) //possible loop
        return result;
    if ($items[dense meat stack,meat stack] contains it) return listMake(it); //meat from yesterday + fairy gravy boat? hmm... no
	if (it.available_amount() >= it_amounted_needed)
        return result;
	int [item] ingredients = get_ingredients_fast(it);
	if (ingredients.count() == 0)
    {
        for i from 1 to (it_amounted_needed - it.available_amount())
            result.listAppend(it);
    }
	foreach ingredient in ingredients
	{
		int ingredient_amounted_needed = ingredients[ingredient];
		if (ingredient.available_amount() >= ingredient_amounted_needed) //have enough
            continue;
		//split:
		item [int] r = missingComponentsToMakeItemPrivateImplementation(ingredient, ingredient_amounted_needed, recursion_limit_remaining - 1);
        if (r.count() > 0)
        {
            result.listAppendList(r);
        }
	}
	return result;
}

item [int] missingComponentsToMakeItem(item it, int it_amounted_needed)
{
    return missingComponentsToMakeItemPrivateImplementation(it, it_amounted_needed, 30);
}


item [int] missingComponentsToMakeItem(item it)
{
    return missingComponentsToMakeItem(it, 1);
}

string [int] missingComponentsToMakeItemInHumanReadableFormat(item it)
{
    item [int] parts = missingComponentsToMakeItem(it);
    
    int [item] parts_inverted;
    foreach key, it2 in parts
    {
        parts_inverted[it2] += 1;
    }
    string [int] result;
    foreach it2, amount in parts_inverted
    {
        string line = amount;
        line += " more ";
        if (amount > 1)
            line += it2.plural;
        else
            line += it2.to_string();
        result.listAppend(line);
    }
    return result;
}

//For tracking time deltas. Won't accurately compare across day boundaries and isn't monotonic (be wary of negative deltas), but still useful for temporal rate limiting.
int getMillisecondsOfToday()
{
    //To replicate value in GCLI:
    //ash (now_to_string("H").to_int() * 60 * 60 * 1000 + now_to_string("m").to_int() * 60 * 1000 + now_to_string("s").to_int() * 1000 + now_to_string("S").to_int())
    return now_to_string("H").to_int_silent() * 60 * 60 * 1000 + now_to_string("m").to_int_silent() * 60 * 1000 + now_to_string("s").to_int_silent() * 1000 + now_to_string("S").to_int_silent();
}

//WARNING: Only accurate for up to five turns.
//It also will not work properly in certain areas, and possibly across day boundaries. Actually, it's kind of a hack.
//But now we have turns_spent so no need to worry.
int combatTurnsAttemptedInLocation(location place)
{
    int count = 0;
    if (place.combat_queue != "")
        count += place.combat_queue.split_string_alternate("; ").count();
    return count;
}

int noncombatTurnsAttemptedInLocation(location place)
{
    int count = 0;
    if (place.noncombat_queue != "")
        count += place.noncombat_queue.split_string_alternate("; ").count();
    return count;
}

int turnsAttemptedInLocation(location place)
{
    return place.turns_spent;
}

int turnsAttemptedInLocation(boolean [location] places)
{
    int count = 0;
    foreach place in places
        count += place.turnsAttemptedInLocation();
    return count;
}

string [int] locationSeenNoncombats(location place)
{
    return place.noncombat_queue.split_string_alternate("; ");
}

string [int] locationSeenCombats(location place)
{
    return place.combat_queue.split_string_alternate("; ");
}

string lastNoncombatInLocation(location place)
{
    if (place.noncombat_queue != "")
        return place.locationSeenNoncombats().listLastObject();
    return "";
}

string lastCombatInLocation(location place)
{
    if (place.noncombat_queue != "")
        return place.locationSeenCombats().listLastObject();
    return "";
}

static
{
    int [location] __place_delays;
    __place_delays[$location[the spooky forest]] = 5;
    __place_delays[$location[the haunted bedroom]] = 6; //a guess from spading
    __place_delays[$location[the boss bat's lair]] = 4;
    __place_delays[$location[the oasis]] = 5;
    __place_delays[$location[the hidden park]] = 6; //6? does turkey blaster give four turns sometimes...?
    __place_delays[$location[the haunted gallery]] = 5; //FIXME this is a guess, spade
    __place_delays[$location[the haunted bathroom]] = 5;
    __place_delays[$location[the haunted ballroom]] = 5; //FIXME rumored
    __place_delays[$location[the penultimate fantasy airship]] = 25;
    __place_delays[$location[the "fun" house]] = 10;
    __place_delays[$location[The Castle in the Clouds in the Sky (Ground Floor)]] = 10;
    __place_delays[$location[the outskirts of cobb's knob]] = 10;
    __place_delays[$location[the hidden apartment building]] = 8;
    __place_delays[$location[the hidden office building]] = 10;
    __place_delays[$location[the upper chamber]] = 5;
}

int totalDelayForLocation(location place)
{
    //the haunted billiards room does not contain delay
    //also failure at 16 skill
    
    if (__place_delays contains place)
        return __place_delays[place];
    return -1;
}

int delayRemainingInLocation(location place)
{
    int delay_for_place = place.totalDelayForLocation();
    
    if (delay_for_place == -1)
        return -1;
    
    int turns_attempted = place.turns_spent;
    
    return MAX(0, delay_for_place - turns_attempted);
}

int turnsCompletedInLocation(location place)
{
    return place.turnsAttemptedInLocation(); //FIXME make this correct
}

//Backwards compatibility:
//We want to be able to support new content with daily builds. But, we don't want to ask users to run a daily build.
//So these act as replacements for new content. Unknown lookups are given as $type[none] The goal is to have compatibility with the last major release.
//We use this instead of to_item() conversion functions, so we can easily identify them in the source.
item lookupItem(string name)
{
    return name.to_item();
}

boolean [item] lookupItems(string names) //CSV input
{
    boolean [item] result;
    string [int] item_names = split_string_alternate(names, ",");
    foreach key in item_names
    {
        item it = item_names[key].to_item();
        if (it == $item[none])
            continue;
        result[it] = true;
    }
    return result;
}

boolean [item] lookupItemsArray(boolean [string] names)
{
    boolean [item] result;
    
    foreach item_name in names
    {
        item it = item_name.to_item();
        if (it == $item[none])
            continue;
        result[it] = true;
    }
    return result;
}

skill lookupSkill(string name)
{
    return name.to_skill();
}

boolean [skill] lookupSkills(string names) //CSV input
{
    boolean [skill] result;
    string [int] skill_names = split_string_alternate(names, ",");
    foreach key in skill_names
    {
        skill s = skill_names[key].to_skill();
        if (s == $skill[none])
            continue;
        result[s] = true;
    }
    return result;
}


//lookupSkills(string) will be called instead if we keep the same name, so use a different name:
boolean [skill] lookupSkillsInt(boolean [int] skill_ids)
{
    boolean [skill] result;
    foreach skill_id in skill_ids
    {
        skill s = skill_id.to_skill();
        if (s == $skill[none])
            continue;
        result[s] = true;
    }
    return result;
}

effect lookupEffect(string name)
{
    return name.to_effect();
}

familiar lookupFamiliar(string name)
{
    return name.to_familiar();
}

location lookupLocation(string name)
{
    return name.to_location();
    /*l = name.to_location();
    if (__setting_debug_mode && l == $location[none])
        print_html("Unable to find location \"" + name + "\"");
    return l;*/
}

boolean [location] lookupLocations(string names_string)
{
    boolean [location] result;
    
    string [int] names = names_string.split_string(",");
    foreach key, name in names
    {
        if (name.length() == 0)
            continue;
        location l = name.to_location();
        if (l != $location[none])
            result[l] = true;
    }
    
    return result;
}

monster lookupMonster(string name)
{
    return name.to_monster();
}

boolean [monster] lookupMonsters(string names_string)
{
    boolean [monster] result;
    
    string [int] names = names_string.split_string(",");
    foreach key, name in names
    {
        if (name.length() == 0)
            continue;
        monster m = name.to_monster();
        if (m != $monster[none])
            result[m] = true;
    }
    
    return result;
}

class lookupClass(string name)
{
    return name.to_class();
}

boolean monsterDropsItem(monster m, item it)
{
	//record [int] drops = m.item_drops_array();
	foreach key in m.item_drops_array()
	{
		if (m.item_drops_array()[key].drop == it)
			return true;
	}
	return false;
}


Record StringHandle
{
    string s;
};

Record FloatHandle
{
    float f;
};


buffer generateTurnsToSeeNoncombat(int combat_rate, int noncombats_in_zone, string task, int max_turns_between_nc, int extra_starting_turns)
{
    float turn_estimation = -1.0;
    float combat_rate_modifier = combat_rate_modifier();
    float noncombat_rate = 1.0 - (combat_rate + combat_rate_modifier).to_float() / 100.0;
    
    
    if (noncombats_in_zone > 0)
    {
        float minimum_nc_rate = 0.0;
        if (max_turns_between_nc != 0)
            minimum_nc_rate = 1.0 / max_turns_between_nc.to_float();
        if (noncombat_rate < minimum_nc_rate)
            noncombat_rate = minimum_nc_rate;
        
        if (noncombat_rate > 0.0)
            turn_estimation = noncombats_in_zone.to_float() / noncombat_rate;
    }
    else
        turn_estimation = 0.0;
    
    turn_estimation += extra_starting_turns;
    
    
    buffer result;
    
    if (turn_estimation == -1.0)
    {
        result.append("Impossible");
    }
    else
    {
        result.append("~");
        result.append(turn_estimation.roundForOutput(1));
        if (turn_estimation == 1.0)
            result.append(" turn");
        else
            result.append(" turns");
    }
    
    if (task != "")
    {
        result.append(" to ");
        result.append(task);
    }
    else
    {
        if (turn_estimation == -1.0)
        {
        }
        else if (turn_estimation == 1.0)
            result.append(" remains");
        else
            result.append(" remain");
    }
    if (noncombats_in_zone > 0)
    {
        result.append(" at ");
        result.append(combat_rate_modifier.floor());
        result.append("% combat rate");
    }
    result.append(".");
    
    return result;
}

buffer generateTurnsToSeeNoncombat(int combat_rate, int noncombats_in_zone, string task, int max_turns_between_nc)
{
    return generateTurnsToSeeNoncombat(combat_rate, noncombats_in_zone, task, max_turns_between_nc, 0);
}

buffer generateTurnsToSeeNoncombat(int combat_rate, int noncombats_in_zone, string task)
{
    return generateTurnsToSeeNoncombat(combat_rate, noncombats_in_zone, task, 0);
}


int damageTakenByElement(int base_damage, float elemental_resistance)
{
    if (base_damage < 0)
        return 1;
    
    float effective_base_damage = MAX(30, base_damage).to_float();
    
    return MAX(1, ceil(base_damage.to_float() - effective_base_damage * elemental_resistance));
}

int damageTakenByElement(int base_damage, element e)
{
    float elemental_resistance = e.elemental_resistance() / 100.0;
    
    //mafia might already do this for us already, but I haven't checked:
    
    if (e == $element[cold] && $effect[coldform].have_effect() > 0)
        elemental_resistance = 1.0;
    else if (e == $element[hot] && $effect[hotform].have_effect() > 0)
        elemental_resistance = 1.0;
    else if (e == $element[sleaze] && $effect[sleazeform].have_effect() > 0)
        elemental_resistance = 1.0;
    else if (e == $element[spooky] && $effect[spookyform].have_effect() > 0)
        elemental_resistance = 1.0;
    else if (e == $element[stench] && $effect[stenchform].have_effect() > 0)
        elemental_resistance = 1.0;
        
        
    return damageTakenByElement(base_damage, elemental_resistance);
}

boolean locationHasPlant(location l, string plant_name)
{
    string [int] plants_in_place = get_florist_plants()[l];
    foreach key in plants_in_place
    {
        if (plants_in_place[key] == plant_name)
            return true;
    }
    return false;
}

float initiative_modifier_ignoring_plants()
{
    //FIXME strange bug here, investigate
    //seen in cyrpt
    float init = initiative_modifier();
    
    location my_location = my_location();
    if (my_location != $location[none] && (my_location.locationHasPlant("Impatiens") || my_location.locationHasPlant("Shuffle Truffle")))
        init -= 25.0;
    
    return init;
}

float item_drop_modifier_ignoring_plants()
{
    float modifier = item_drop_modifier();
    
    location my_location = my_location();
    if (my_location != $location[none])
    {
        if (my_location.locationHasPlant("Rutabeggar") || my_location.locationHasPlant("Stealing Magnolia"))
            modifier -= 25.0;
        if (my_location.locationHasPlant("Kelptomaniac"))
            modifier -= 40.0;
    }
    return modifier;
}

int monster_level_adjustment_ignoring_plants() //this is unsafe to use in heavy rains
{
    //FIXME strange bug possibly here, investigate
    int ml = monster_level_adjustment();
    
    location my_location = my_location();
    
    if (my_location != $location[none])
    {
        string [3] location_plants = get_florist_plants()[my_location];
        foreach key in location_plants
        {
            string plant = location_plants[key];
            if (plant == "Rabid Dogwood" || plant == "War Lily"  || plant == "Blustery Puffball")
            {
                ml -= 30;
                break;
            }
        }
        
    }
    return ml;
}

int water_level_of_location(location l)
{
    int water_level = 1;
    if (l.recommended_stat >= 40) //FIXME is this threshold spaded?
        water_level += 1;
    if (l.environment == "indoor")
        water_level += 2;
    if (l.environment == "underground" || l == $location[the lower chambers]) //per-location fix
        water_level += 4;
    water_level += numeric_modifier("water level");
    
    water_level = clampi(water_level, 1, 6);
    if (l.environment == "underwater") //or does the water get the rain instead? nobody knows, rain man
        water_level = 0; //the aquaman hates rain man, they have a fight, aquaman wins
    return water_level;
}

float washaway_rate_of_location(location l)
{
    //Calculate washaway chance:
    int current_water_level = l.water_level_of_location();
    
    int washaway_chance = current_water_level * 5;
    if ($item[fishbone catcher's mitt].equipped_amount() > 0)
        washaway_chance -= 15; //GUESS
    
    if ($effect[Fishy Whiskers].have_effect() > 0)
    {
        //washaway_chance -= ?; //needs spading
    }
    return clampNormalf(washaway_chance / 100.0);
}

int monster_level_adjustment_for_location(location l)
{
    int ml = monster_level_adjustment_ignoring_plants();
    
    if (l.locationHasPlant("Rabid Dogwood") || l.locationHasPlant("War Lily") || l.locationHasPlant("Blustery Puffball"))
    {
        ml += 30;
    }
    
    if (my_path_id() == PATH_HEAVY_RAINS)
    {
        //complicated:
        //First, cancel out the my_location() rain:
        int my_location_water_level_ml = monster_level_adjustment() - numeric_modifier("Monster Level");
        ml -= my_location_water_level_ml;
        
        //Now, calculate the water level for the location:
        int water_level = water_level_of_location(l);
        
        //Add that as ML:
        if (!($locations[oil peak,the typical tavern cellar] contains l)) //kind of hacky to put this here, sorry
        {
            ml += water_level * 10;
        }
    }
    
    return ml;
}

float initiative_modifier_for_location(location l)
{
    float base = initiative_modifier_ignoring_plants();
    
    if (l.locationHasPlant("Impatiens") || l.locationHasPlant("Shuffle Truffle"))
        base += 25.0;
    return base;
}

float item_drop_modifier_for_location(location l)
{
    int base = item_drop_modifier_ignoring_plants();
    if (l.locationHasPlant("Rutabeggar") || l.locationHasPlant("Stealing Magnolia"))
        base += 25.0;
    if (l.locationHasPlant("Kelptomaniac"))
        base += 40.0;
    return base;
}

int monsterExtraInitForML(int ml)
{
	if (ml < 21)
		return 0.0;
	else if (ml < 41)
		return 0.0 + 1.0 * (ml - 20.0);
	else if (ml < 61)
		return 20.0 + 2.0 * (ml - 40.0);
	else if (ml < 81)
		return 60.0 + 3.0 * (ml - 60.0);
	else if (ml < 101)
		return 120.0 + 4.0 * (ml - 80.0);
	else
		return 200.0 + 5.0 * (ml - 100.0);
}

int stringCountSubstringMatches(string str, string substring)
{
    int count = 0;
    int position = 0;
    int breakout = 100;
    int str_length = str.length(); //uncertain whether this is a constant time operation
    while (breakout > 0 && position + 1 < str_length)
    {
        position = str.index_of(substring, position + 1);
        if (position != -1)
            count += 1;
        else
            break;
        breakout -= 1;
    }
    return count;
}

effect to_effect(item it)
{
	return it.effect_modifier("effect");
}



boolean weapon_is_club(item it)
{
    if (it.to_slot() != $slot[weapon]) return false;
    if (it.item_type() == "club")
        return true;
    if (it.item_type() == "sword" && $effect[Iron Palms].have_effect() > 0)
        return true;
    return false;
}

buffer prepend(buffer in_buffer, buffer value)
{
    buffer result;
    result.append(value);
    result.append(in_buffer);
    in_buffer.set_length(0);
    in_buffer.append(result);
    return result;
}

buffer prepend(buffer in_buffer, string value)
{
    return prepend(in_buffer, value.to_buffer());
}

float pressurePenaltyForLocation(location l, Error could_get_value)
{
    float pressure_penalty = 0.0;
    
    if (my_location() != l)
    {
        ErrorSet(could_get_value);
        return -1.0;
    }
    
    pressure_penalty = MAX(0, -numeric_modifier("item drop penalty"));
    return pressure_penalty;
}

int XiblaxianHoloWristPuterTurnsUntilNextItem()
{
    int drops = get_property_int("_holoWristDrops");
    int progress = get_property_int("_holoWristProgress");
    
    //_holoWristProgress resets when drop happens
    if (!mafiaIsPastRevision(15148))
        return -1;
    int next_turn_hit = 5 * (drops + 1) + 6;
    if (!mafiaIsPastRevision(15493)) //old behaviour
    {
        if (drops != 0)
            next_turn_hit += 1;
    }
    return MAX(0, next_turn_hit - progress);
}

int ka_dropped(monster m)
{
    if (m.phylum == $phylum[dude] || m.phylum == $phylum[hobo] || m.phylum == $phylum[hippy] || m.phylum == $phylum[pirate])
        return 2;
    if (m.phylum == $phylum[goblin] || m.phylum == $phylum[humanoid] || m.phylum == $phylum[beast] || m.phylum == $phylum[bug] || m.phylum == $phylum[orc] || m.phylum == $phylum[elemental] || m.phylum == $phylum[elf] || m.phylum == $phylum[penguin])
        return 1;
    return 0;
}


boolean is_underwater_familiar(familiar f)
{
    return $familiars[Barrrnacle,Emo Squid,Cuddlefish,Imitation Crab,Magic Dragonfish,Midget Clownfish,Rock Lobster,Urchin Urchin,Grouper Groupie,Squamous Gibberer,Dancing Frog,Adorable Space Buddy] contains f;
}

float calculateCurrentNinjaAssassinMaxDamage()
{
    
	//float assassin_ml = 155.0 + monster_level_adjustment();
    float assassin_ml = $monster[ninja snowman assassin].base_attack + 5.0;
	float damage_absorption = raw_damage_absorption();
	float damage_reduction = damage_reduction();
	float moxie = my_buffedstat($stat[moxie]);
	float cold_resistance = numeric_modifier("cold resistance");
	float v = 0.0;
	
	//spaded by yojimboS_LAW
	//also by soirana
    
	float myst_class_extra_cold_resistance = 0.0;
	if (my_class() == $class[pastamancer] || my_class() == $class[sauceror] || my_class() == $class[avatar of jarlsberg])
		myst_class_extra_cold_resistance = 0.05;
	//Direct from the spreadsheet:
	if (cold_resistance < 9)
		v = ((((MAX((assassin_ml - moxie), 0.0) - damage_reduction) + 120.0) * MAX(0.1, MIN((1.1 - sqrt((damage_absorption/1000.0))), 1.0))) * ((1.0 - myst_class_extra_cold_resistance) - ((0.1) * MAX((cold_resistance - 5.0), 0.0))));
	else
		v = ((((MAX((assassin_ml - moxie), 0.0) - damage_reduction) + 120.0) * MAX(0.1, MIN((1.1 - sqrt((damage_absorption/1000.0))), 1.0))) * (0.1 - myst_class_extra_cold_resistance + (0.5 * (powf((5.0/6.0), (cold_resistance - 9.0))))));
	
    
    
	return v;
}

float calculateCurrentNinjaAssassinMaxEnvironmentalDamage()
{
    float v = 0.0;
    int ml_level = monster_level_adjustment_ignoring_plants();
    if (ml_level >= 25)
    {
        float expected_assassin_damage = 0.0;
        
        expected_assassin_damage = ((150 + ml_level) * (ml_level - 25)).to_float() / 500.0;
        
        expected_assassin_damage = expected_assassin_damage + ceiling(expected_assassin_damage / 11.0); //upper limit
        
        //FIXME add in resists later
        //Resists don't work properly. They have an effect, but it's different. I don't know how much exactly, so for now, ignore this:
        //I think they're probably just -5 like above
        //expected_assassin_damage = damageTakenByElement(expected_assassin_damage, $element[cold]);
        
        expected_assassin_damage = ceil(expected_assassin_damage);
        
        v += expected_assassin_damage;
    }
    return v;
}

//mafia describes "merkin" for the "mer-kin" phylum, which "to_phylum()" does not interpret
//hmm... maybe file a request for to_phylum() to parse that
phylum getDNASyringePhylum()
{
    string phylum_text = get_property("dnaSyringe");
    if (phylum_text == "merkin")
        return $phylum[mer-kin];
    else
        return phylum_text.to_phylum();
}

int nextLibramSummonMPCost()
{
    int libram_summoned = get_property_int("libramSummons");
    int next_libram_summoned = libram_summoned + 1;
    int libram_mp_cost = MAX(1 + (next_libram_summoned * (next_libram_summoned - 1)/2) + mana_cost_modifier(), 1);
    return libram_mp_cost;
}

int equippable_amount(item it)
{
    if (!it.can_equip()) return it.equipped_amount();
    if (it.available_amount() == 0) return 0;
    if ($slots[acc1, acc2, acc3] contains it.to_slot() && it.available_amount() > 1 && !it.boolean_modifier("Single equip"))
        return MIN(3, it.available_amount());
    if (it.to_slot() == $slot[weapon] && it.weapon_hands() == 1)
    {
        int weapon_maximum = 1;
        if ($skill[double-fisted skull smashing].skill_is_usable())
            weapon_maximum += 1;
        if (my_familiar() == $familiar[disembodied hand])
            weapon_maximum += 1;
        return MIN(weapon_maximum, it.available_amount());
    }
    return 1;
}

boolean haveSeenBadMoonEncounter(int encounter_id)
{
    if (!get_property_ascension("lastBadMoonReset")) //badMoonEncounter values are not reset when you ascend
        return false;
    return get_property_boolean("badMoonEncounter" + encounter_id);
}

//FIXME make this use static etc. Probably extend Item Filter.ash to support equipment.
item [int] generateEquipmentForExtraExperienceOnStat(stat desired_stat, boolean require_can_equip_currently)
{
    //boolean [item] experience_percent_modifiers;
    /*string numeric_modifier_string;
    if (desired_stat == $stat[muscle])
    {
        //experience_percent_modifiers = $items[trench lighter,fake washboard];
        numeric_modifier_string = "Muscle";
    }
    else if (desired_stat == $stat[mysticality])
    {
        //experience_percent_modifiers = lookupItems("trench lighter,basaltamander buckler");
        numeric_modifier_string = "Mysticality";
    }
    else if (desired_stat == $stat[moxie])
    {
        //experience_percent_modifiers = $items[trench lighter,backwoods banjo];
        numeric_modifier_string = "Moxie";
    }
    else
        return listMakeBlankItem();
    if (numeric_modifier_string != "")
        numeric_modifier_string += " Experience Percent";*/
        
    item [slot] item_slots;
    string numeric_modifier_string = desired_stat + " Experience Percent";

    //foreach it in experience_percent_modifiers
    foreach it in equipmentWithNumericModifier(numeric_modifier_string)
    {
    	slot s = it.to_slot();
        if (s == $slot[shirt] && !($skill[Torso Awaregness].have_skill() || $skill[Best Dressed].have_skill()))
        	continue;
        if (it.available_amount() > 0 && (!require_can_equip_currently || it.can_equip()) && item_slots[it.to_slot()].numeric_modifier(numeric_modifier_string) < it.numeric_modifier(numeric_modifier_string))
        {
            item_slots[it.to_slot()] = it;
        }
    }
    
    item [int] items_could_equip;
    foreach s, it in item_slots
        items_could_equip.listAppend(it);
    return items_could_equip;
}


item [int] generateEquipmentToEquipForExtraExperienceOnStat(stat desired_stat)
{
    item [int] items_could_equip = generateEquipmentForExtraExperienceOnStat(desired_stat, true);
    item [int] items_equipping;
    foreach key, it in items_could_equip
    {
        if (it.equipped_amount() == 0)
        {
            items_equipping.listAppend(it);
        }
    }
    return items_equipping;
}



float averageAdventuresForConsumable(item it, boolean assume_monday)
{
	float adventures = 0.0;
	string [int] adventures_string = it.adventures.split_string("-");
	foreach key, v in adventures_string
	{
		float a = v.to_float();
		if (a < 0)
			continue;
		adventures += a * (1.0 / to_float(adventures_string.count()));
	}
    if (it == lookupItem("affirmation cookie"))
        adventures += 3;
    if (it == $item[White Citadel burger])
    {
        if (in_bad_moon())
            adventures = 2; //worst case scenario
        else
            adventures = 9; //saved across lifetimes
    }
	
	if ($skill[saucemaven].have_skill() && $items[hot hi mein,cold hi mein,sleazy hi mein,spooky hi mein,stinky hi mein,Hell ramen,fettucini Inconnu,gnocchetti di Nietzsche,spaghetti with Skullheads,spaghetti con calaveras] contains it)
	{
		if ($classes[sauceror,pastamancer] contains my_class())
			adventures += 5;
		else
			adventures += 3;
	}
	
    
	if ($skill[pizza lover].have_skill() && it.to_lower_case().contains_text("pizza"))
	{
		adventures += it.fullness;
	}
	if (it.to_lower_case().contains_text("lasagna") && !assume_monday)
		adventures += 5;
	//FIXME lasagna properly
	return adventures;
}

float averageAdventuresForConsumable(item it)
{
    return averageAdventuresForConsumable(it, false);
}

boolean [string] getInstalledSourceTerminalSingleChips()
{
    string [int] chips = get_property("sourceTerminalChips").split_string_alternate(",");
    boolean [string] result;
    foreach key, s in chips
        result[s] = true;
    return result;
}

boolean [skill] getActiveSourceTerminalSkills()
{
    string skill_1_name = get_property("sourceTerminalEducate1");
    string skill_2_name = get_property("sourceTerminalEducate2");
    
    boolean [skill] skills_have;
    if (skill_1_name != "")
        skills_have[skill_1_name.replace_string(".edu", "").to_skill()] = true;
    if (skill_2_name != "")
        skills_have[skill_2_name.replace_string(".edu", "").to_skill()] = true;
    return skills_have;
}

boolean monsterIsGhost(monster m)
{
    if (m.attributes.contains_text("GHOST"))
        return true;
    /*if ($monsters[Ancient ghost,Ancient protector spirit,Banshee librarian,Battlie Knight Ghost,Bettie Barulio,Chalkdust wraith,Claybender Sorcerer Ghost,Cold ghost,Contemplative ghost,Dusken Raider Ghost,Ghost,Ghost miner,Hot ghost,Lovesick ghost,Marcus Macurgeon,Marvin J. Sunny,Mayor Ghost,Mayor Ghost (Hard Mode),Model skeleton,Mortimer Strauss,Plaid ghost,Protector Spectre,Sexy sorority ghost,Sheet ghost,Sleaze ghost,Space Tourist Explorer Ghost,Spirit of New Wave (Inner Sanctum),Spooky ghost,Stench ghost,The ghost of Phil Bunion,Whatsian Commando Ghost,Wonderful Winifred Wongle] contains m)
        return true;
    if ($monsters[boneless blobghost,the ghost of Vanillica \"Trashblossom\" Gorton,restless ghost,The Icewoman,the ghost of Monsieur Baguelle,The ghost of Lord Montague Spookyraven,The Headless Horseman,The ghost of Ebenoozer Screege,The ghost of Sam McGee,The ghost of Richard Cockingham,The ghost of Jim Unfortunato,The ghost of Waldo the Carpathian,the ghost of Oily McBindle] contains m)
        return true;
    if (lookupMonster("Emily Koops, a spooky lime") == m)
        return true;*/
    return false;
}

boolean item_is_pvp_stealable(item it)
{
	if (it == $item[amulet of yendor])
		return true;
	if (!it.tradeable)
		return false;
	if (!it.discardable)
		return false;
	if (it.quest)
		return false;
	if (it.gift)
		return false;
	return true;
}

int effective_familiar_weight(familiar f)
{
    int weight = f.familiar_weight();
    
    boolean is_moved = false;
    string [int] familiars_used_on = get_property("_feastedFamiliars").split_string_alternate(";");
    foreach key, f_name in familiars_used_on
    {
        if (f_name.to_familiar() == f)
        {
            is_moved = true;
            break;
        }
    }
    if (is_moved)
        weight += 10;
    return weight;
}

boolean year_is_leap_year(int year)
{
    if (year % 4 != 0) return false;
    if (year % 100 != 0) return true;
    if (year % 400 != 0) return false;
    return true;
}

boolean today_is_pvp_season_end()
{
    string today = format_today_to_string("MMdd");
    if (today == "0228")
    {
        int year = format_today_to_string("yyyy").to_int();
        boolean is_leap_year = year_is_leap_year(year);
        if (!is_leap_year)
            return true;
    }
    else if (today == "0229") //will always be true, but won't always be there
        return true;
    else if (today == "0430")
        return true;
    else if (today == "0630")
        return true;
    else if (today == "0831")
        return true;
    else if (today == "1031")
        return true;
    else if (today == "1231")
        return true;
    return false;
}

boolean monster_has_zero_turn_cost(monster m)
{
    if (m.attributes.contains_text("FREE"))
        return true;
        
    if ($monsters[lynyrd] contains m) return true; //not marked as FREE in attributes
    //if ($monsters[Black Crayon Beast,Black Crayon Beetle,Black Crayon Constellation,Black Crayon Golem,Black Crayon Demon,Black Crayon Man,Black Crayon Elemental,Black Crayon Crimbo Elf,Black Crayon Fish,Black Crayon Goblin,Black Crayon Hippy,Black Crayon Hobo,Black Crayon Shambling Monstrosity,Black Crayon Manloid,Black Crayon Mer-kin,Black Crayon Frat Orc,Black Crayon Penguin,Black Crayon Pirate,Black Crayon Flower,Black Crayon Slime,Black Crayon Undead Thing,Black Crayon Spiraling Shape,broodling seal,Centurion of Sparky,heat seal,hermetic seal,navy seal,Servant of Grodstank,shadow of Black Bubbles,Spawn of Wally,watertight seal,wet seal,lynyrd,BRICKO airship,BRICKO bat,BRICKO cathedral,BRICKO elephant,BRICKO gargantuchicken,BRICKO octopus,BRICKO ooze,BRICKO oyster,BRICKO python,BRICKO turtle,BRICKO vacuum cleaner,Witchess Bishop,Witchess King,Witchess Knight,Witchess Ox,Witchess Pawn,Witchess Queen,Witchess Rook,Witchess Witch,The ghost of Ebenoozer Screege,The ghost of Lord Montague Spookyraven,The ghost of Waldo the Carpathian,The Icewoman,The ghost of Jim Unfortunato,the ghost of Sam McGee,the ghost of Monsieur Baguelle,the ghost of Vanillica "Trashblossom" Gorton,the ghost of Oily McBindle,boneless blobghost,The ghost of Richard Cockingham,The Headless Horseman,Emily Koops\, a spooky lime,time-spinner prank,random scenester,angry bassist,blue-haired girl,evil ex-girlfriend,peeved roommate] contains m)
        //return true;
    if (m == $monster[x-32-f combat training Snowman] && get_property_int("_snojoFreeFights") < 10)
        return true;
    if (my_familiar() == $familiar[machine elf] && my_location() == $location[the deep machine tunnels] && get_property_int("_machineTunnelsAdv") < 5)
        return true;
    return false;
}

static
{
    int [location] __location_combat_rates;
}
void initialiseLocationCombatRates()
{
    if (__location_combat_rates.count() > 0)
        return;
    int [location] rates;
    file_to_map("data/combats.txt", __location_combat_rates);
    //needs spading:
    foreach l in $locations[the spooky forest]
        __location_combat_rates[l] = 85;
    __location_combat_rates[$location[the black forest]] = 95; //can't remember if this is correct
    __location_combat_rates[$location[inside the palindome]] = 80; //this is not accurate, there's probably a turn cap or something
    __location_combat_rates[$location[The Haunted Billiards Room]] = 85; //completely and absolutely wrong and unspaded; just here to make another script work
    foreach l in $locations[the haunted gallery, the haunted bathroom, the haunted ballroom]
        __location_combat_rates[l] = 90; //or 95? can't remember
    __location_combat_rates[$location[Twin Peak]] = 90; //FIXME assumption
    //print_html("__location_combat_rates = " + __location_combat_rates.to_json());
}
//initialiseLocationCombatRates();
int combatRateOfLocation(location l)
{
    initialiseLocationCombatRates();
    //Some revamps changed the combat rate; here we have some not-quite-true-but-close assumptions:
    if (l == $location[the haunted ballroom])
        return 95;
    if (__location_combat_rates contains l)
    {
        int rate = __location_combat_rates[l];
        if (rate < 0)
            rate = 100;
        return rate;
    }
    return 100; //Unknown
    
    /*float base_rate = l.appearance_rates()[$monster[none]];
    if (base_rate == 0.0)
        return 0;
    return base_rate + combat_rate_modifier();*/
}

//Specifically checks whether you can eat this item right now - fullness/drunkenness, meat, etc.
boolean CafeItemEdible(item it)
{
    //Mafia does not seem to support accessing its cafe data via ASH.
    //So, do the same thing. There's four mafia supports - Chez Snootee, Crimbo Cafe, Hell's Kitchen, and MicroBrewery.
    if (it.fullness > availableFullness())
        return false;
    if (it.inebriety > availableDrunkenness())
        return false;
    //FIXME rest
    if (it == $item[Jumbo Dr. Lucifer] && in_bad_moon() && my_meat() >= 150)
        return true;
    return false;
}

static
{
    int [string] __lta_social_capital_purchases;
    void initialiseLTASocialCapitalPurchases()
    {
        __lta_social_capital_purchases["bondAdv"] = 1;
        __lta_social_capital_purchases["bondBeach"] = 1;
        __lta_social_capital_purchases["bondBeat"] = 1;
        __lta_social_capital_purchases["bondBooze"] = 2;
        __lta_social_capital_purchases["bondBridge"] = 3;
        __lta_social_capital_purchases["bondDR"] = 1;
        __lta_social_capital_purchases["bondDesert"] = 5;
        __lta_social_capital_purchases["bondDrunk1"] = 2;
        __lta_social_capital_purchases["bondDrunk2"] = 3;
        __lta_social_capital_purchases["bondHP"] = 1;
        __lta_social_capital_purchases["bondHoney"] = 5;
        __lta_social_capital_purchases["bondInit"] = 1;
        __lta_social_capital_purchases["bondItem1"] = 1;
        __lta_social_capital_purchases["bondItem2"] = 2;
        __lta_social_capital_purchases["bondItem3"] = 4;
        __lta_social_capital_purchases["bondJetpack"] = 3;
        __lta_social_capital_purchases["bondMPregen"] = 3;
        __lta_social_capital_purchases["bondMartiniDelivery"] = 1;
        __lta_social_capital_purchases["bondMartiniPlus"] = 3;
        __lta_social_capital_purchases["bondMartiniTurn"] = 1;
        __lta_social_capital_purchases["bondMeat"] = 1;
        __lta_social_capital_purchases["bondMox1"] = 1;
        __lta_social_capital_purchases["bondMox2"] = 3;
        __lta_social_capital_purchases["bondMus1"] = 1;
        __lta_social_capital_purchases["bondMus2"] = 3;
        __lta_social_capital_purchases["bondMys1"] = 1;
        __lta_social_capital_purchases["bondMys2"] = 3;
        __lta_social_capital_purchases["bondSpleen"] = 4;
        __lta_social_capital_purchases["bondStat"] = 2;
        __lta_social_capital_purchases["bondStat2"] = 4;
        __lta_social_capital_purchases["bondStealth"] = 3;
        __lta_social_capital_purchases["bondStealth2"] = 4;
        __lta_social_capital_purchases["bondSymbols"] = 3;
        __lta_social_capital_purchases["bondWar"] = 3;
        __lta_social_capital_purchases["bondWeapon2"] = 3;
        __lta_social_capital_purchases["bondWpn"] = 1;
    }
    initialiseLTASocialCapitalPurchases();
}

int licenseToAdventureSocialCapitalAvailable()
{
    int total_social_capital = 0;
    total_social_capital += 1 + MIN(23, get_property_int("bondPoints"));
    foreach level in $ints[3,6,9,12,15]
    {
        if (my_level() >= level)
            total_social_capital += 1;
    }
    total_social_capital += 2 * get_property_int("bondVillainsDefeated");
    
    
    
    int social_capital_used = 0;
    foreach property_name, value in __lta_social_capital_purchases
    {
        if (get_property_boolean(property_name))
            social_capital_used += value;
    }
    //print_html("total_social_capital = " + total_social_capital + ", social_capital_used = " + social_capital_used);
    
    return total_social_capital - social_capital_used;
}



monster convertEncounterToMonster(string encounter)
{
    boolean [string] intergnat_strings;
    intergnat_strings[" WITH SCIENCE!"] = true;
    intergnat_strings["ELDRITCH HORROR "] = true;
    intergnat_strings[" WITH BACON!!!"] = true;
    intergnat_strings[" NAMED NEIL"] = true;
    intergnat_strings[" AND TESLA!"] = true;
    foreach s in intergnat_strings
    {
        if (encounter.contains_text(s))
            encounter = encounter.replace_string(s, "");
    }
    if (encounter == "The Junk") //not a junksprite
        return $monster[junk];
    if ((encounter.stringHasPrefix("the ") || encounter.stringHasPrefix("The")) && encounter.to_monster() == $monster[none])
    {
        encounter = encounter.substring(4);
        //print_html("now \"" + encounter + "\"");
    }
    //if (encounter == "the X-32-F Combat Training Snowman")
        //return $monster[X-32-F Combat Training Snowman];
    if (encounter == "clingy pirate")
        return $monster[clingy pirate (male)]; //always accurate for my personal data
    return encounter.to_monster();
}

//Returns [0, 100]
float resistanceLevelToResistancePercent(float level)
{
	float m = 0;
	if (my_primestat() == $stat[mysticality])
		m = 5;
	if (level <= 3) return 10 * level + m;
    return 90 - 50 * powf(5.0 / 6.0, level - 4) + m;
}


//Mafia's text output doesn't handle very long strings with no spaces in them - they go horizontally past the text box. This is common for to_json()-types.
//So, add spaces every so often if we need them:
buffer processStringForPrinting(string str)
{
    buffer out;
    int limit = 50;
    int comma_limit = 25;
    int characters_since_space = 0;
    for i from 0 to str.length() - 1
    {
        if (str.length() == 0) break;
        string c = str.char_at(i);
        out.append(c);
        
        if (c == " ")
            characters_since_space = 0;
        else
        {
            characters_since_space++;
            if (characters_since_space >= limit || (c == "," && characters_since_space >= comma_limit)) //prefer adding spaces after a comma
            {
                characters_since_space = 0;
                out.append(" ");
            }
        }
    }
    return out;
}
void printSilent(string line, string font_colour)
{
    print_html("<font color=\"" + font_colour + "\">" + line.processStringForPrinting() + "</font>");
}

void printSilent(string line)
{
    print_html(line.processStringForPrinting());
}
//Allows fast querying of which effects have which numeric_modifier()s.

//Modifiers are lower case.
static
{
	boolean [effect][string] __modifiers_for_effect;
	boolean [string][effect] __effects_for_modifiers;
	boolean [effect] __effect_contains_non_constant_modifiers; //meaning, numeric_modifier() cannot be cached
}
void initialiseModifiers()
{
	if (__modifiers_for_effect.count() != 0) return;
	//boolean [string] modifier_types;
	//boolean [string] modifier_values;
	foreach e in $effects[]
	{
		string string_modifiers = e.string_modifier("Modifiers");
        if (string_modifiers == "") continue;
        if (string_modifiers.contains_text("Avatar: ")) continue; //FIXME parse properly?
        string [int] first_level_split = string_modifiers.split_string(", ");
        
        foreach key, entry in first_level_split
        {
        	//print_html(entry);
            //if (!entry.contains_text(":"))
            
            string modifier_type;
            string modifier_value;
            if (entry.contains_text(": "))
            {
            	string [int] entry_split = entry.split_string(": ");
                modifier_type = entry_split[0];
                modifier_value = entry_split[1];
            }
            else
            	modifier_type = entry;
            
            
            string modifier_type_converted = modifier_type;
            
            //convert modifier_type to modifier_type_converted:
            //FIXME is this all of them?
            if (modifier_type_converted == "Combat Rate (Underwater)")
            	modifier_type_converted = "Underwater Combat Rate";
            else if (modifier_type_converted == "Experience (familiar)")
                modifier_type_converted = "Familiar Experience";
            else if (modifier_type_converted == "Experience (Moxie)")
                modifier_type_converted = "Moxie Experience";
            else if (modifier_type_converted == "Experience (Muscle)")
                modifier_type_converted = "Muscle Experience";
            else if (modifier_type_converted == "Experience (Mysticality)")
                modifier_type_converted = "Mysticality Experience";
            else if (modifier_type_converted == "Experience Percent (Moxie)")
                modifier_type_converted = "Moxie Experience Percent";
            else if (modifier_type_converted == "Experience Percent (Muscle)")
                modifier_type_converted = "Muscle Experience Percent";
            else if (modifier_type_converted == "Experience Percent (Mysticality)")
                modifier_type_converted = "Mysticality Experience Percent";
            else if (modifier_type_converted == "Mana Cost (stackable)")
                modifier_type_converted = "Stackable Mana Cost";
            else if (modifier_type_converted == "Familiar Weight (hidden)")
                modifier_type_converted = "Hidden Familiar Weight";
            else if (modifier_type_converted == "Meat Drop (sporadic)")
                modifier_type_converted = "Sporadic Meat Drop";
            else if (modifier_type_converted == "Item Drop (sporadic)")
                modifier_type_converted = "Sporadic Item Drop";
            
            modifier_type_converted = modifier_type_converted.to_lower_case();
            __modifiers_for_effect[e][modifier_type_converted] = true;
            __effects_for_modifiers[modifier_type_converted][e] = true;
            if (modifier_value.contains_text("[") || modifier_value.contains_text("\""))
            	__effect_contains_non_constant_modifiers[e] = true;
            if (modifier_type_converted ≈ "muscle percent")
            {
            	__modifiers_for_effect[e]["muscle"] = true;
            	__effects_for_modifiers["muscle"][e] = true;
            }
            if (modifier_type_converted ≈ "mysticality percent")
            {
                __modifiers_for_effect[e]["mysticality"] = true;
                __effects_for_modifiers["mysticality"][e] = true;
            }
            if (modifier_type_converted ≈ "moxie percent")
            {
                __modifiers_for_effect[e]["moxie"] = true;
                __effects_for_modifiers["moxie"][e] = true;
            }
            
            /*if (e.numeric_modifier(modifier_type_converted) == 0.0 && modifier_value.length() > 0 && e.string_modifier(modifier_type_converted) == "")// && !__effect_contains_non_constant_modifiers[e])
            {
            	//print_html("No match on \"" + modifier_type_converted + "\"");
                print_html("No match on \"" + modifier_type_converted + "\" for " + e + " (" + string_modifiers + ")");
            }*/
            //modifier_types[modifier_type] = true;
            //modifier_values[modifier_value] = true;
        }
        //return;
	}
	/*print_html("Types:");
	foreach type in modifier_types
	{
		print_html(type);
	}
	print_html("");
    print_html("Values:");
    foreach value in modifier_values
    {
        print_html(value);
    }*/
}
initialiseModifiers();


//Quest status stores all/most of our quest information in an internal format that's easier to understand.
record QuestState
{
	string quest_name;
	string image_name;
	
	boolean startable; //can be started, but hasn't yet
	boolean started;
	boolean in_progress;
	boolean finished;
	
	int mafia_internal_step; //0 for not started. INT32_MAX for finished. This is +1 versus mafia's "step1/step2/stepX" system. "step1" is represented as 2, "step2" as 3, etc.
	
	boolean [string] state_boolean;
	string [string] state_string;
	int [string] state_int;
	float [string] state_float;
	
	boolean council_quest;
};

QuestState [string] __quest_state;
boolean [string] __misc_state;
string [string] __misc_state_string;
int [string] __misc_state_int;
float [string] __misc_state_float;

int QuestStateConvertQuestPropertyValueToNumber(string property_value)
{
	int result = 0;
	if (property_value == "")
		return -1;
	if (property_value == "started")
	{
		result = 1;
	}
	else if (property_value == "finished")
	{
		result = INT32_MAX;
	}
	else if (property_value.contains_text("step"))
	{
		//lazy:
		string theoretical_int = property_value.replace_string(" ", "").replace_string("step", ""); //one revision had a bug that set questL11Worship to "step 4", so remove spaces
		int step_value = theoretical_int.to_int_silent();
		
		result = step_value + 1;
		
		if (result < 0)
			result = 0;
	}
	else
	{
		//unknown
	}
	return result;
}

boolean questPropertyPastInternalStepNumber(string quest_property, int number)
{
	return QuestStateConvertQuestPropertyValueToNumber(get_property(quest_property)) >= number;
}

void QuestStateParseMafiaQuestPropertyValue(QuestState state, string property_value)
{
	state.started = false;
	state.finished = false;
    state.in_progress = false;
	state.mafia_internal_step = QuestStateConvertQuestPropertyValueToNumber(property_value);
	
	if (state.mafia_internal_step > 0)
		state.started = true;
	if (state.mafia_internal_step == INT32_MAX)
		state.finished = true;
	if (state.started && !state.finished)
		state.in_progress = true;
}

boolean QuestStateEquals(QuestState q1, QuestState q2)
{
	//not sure how to do record equality otherwise
	if (q1.quest_name != q2.quest_name)
		return false;
	if (q1.image_name != q2.image_name)
		return false;
	if (q1.startable != q2.startable)
		return false;
	if (q1.started != q2.started)
		return false;
	if (q1.in_progress != q2.in_progress)
		return false;
	if (q1.finished != q2.finished)
		return false;
	if (q1.mafia_internal_step != q2.mafia_internal_step)
		return false;
		
	if (q1.state_boolean != q2.state_boolean)
		return false;
	if (q1.state_string != q2.state_string)
		return false;
	if (q1.state_int != q2.state_int)
		return false;
	return true;
}

void QuestStateParseMafiaQuestProperty(QuestState state, string property_name, boolean allow_quest_log_load)
{
	state.QuestStateParseMafiaQuestPropertyValue(get_property(property_name));
}

void QuestStateParseMafiaQuestProperty(QuestState state, string property_name)
{
    QuestStateParseMafiaQuestProperty(state, property_name, true);
}

QuestState QuestState(string property_name)
{
	QuestState state;
    QuestStateParseMafiaQuestProperty(state, property_name);
    return state;
}
//Comment to allow file_to_map() to see this file:
//Choice	override

boolean [string] __numeric_modifier_names = $strings[Familiar Weight,Monster Level,Combat Rate,Initiative,Experience,Item Drop,Meat Drop,Damage Absorption,Damage Reduction,Cold Resistance,Hot Resistance,Sleaze Resistance,Spooky Resistance,Stench Resistance,Mana Cost,Moxie,Moxie Percent,Muscle,Muscle Percent,Mysticality,Mysticality Percent,Maximum HP,Maximum HP Percent,Maximum MP,Maximum MP Percent,Weapon Damage,Ranged Damage,Spell Damage,Spell Damage Percent,Cold Damage,Hot Damage,Sleaze Damage,Spooky Damage,Stench Damage,Cold Spell Damage,Hot Spell Damage,Sleaze Spell Damage,Spooky Spell Damage,Stench Spell Damage,Underwater Combat Rate,Fumble,HP Regen Min,HP Regen Max,MP Regen Min,MP Regen Max,Adventures,Familiar Weight Percent,Weapon Damage Percent,Ranged Damage Percent,Stackable Mana Cost,Hobo Power,Base Resting HP,Resting HP Percent,Bonus Resting HP,Base Resting MP,Resting MP Percent,Bonus Resting MP,Critical Hit Percent,PvP Fights,Volleyball,Sombrero,Leprechaun,Fairy,Meat Drop Penalty,Hidden Familiar Weight,Item Drop Penalty,Initiative Penalty,Food Drop,Booze Drop,Hat Drop,Weapon Drop,Offhand Drop,Shirt Drop,Pants Drop,Accessory Drop,Volleyball Effectiveness,Sombrero Effectiveness,Leprechaun Effectiveness,Fairy Effectiveness,Familiar Weight Cap,Slime Resistance,Slime Hates It,Spell Critical Percent,Muscle Experience,Mysticality Experience,Moxie Experience,Effect Duration,Candy Drop,DB Combat Damage,Sombrero Bonus,Familiar Experience,Sporadic Meat Drop,Sporadic Item Drop,Meat Bonus,Pickpocket Chance,Combat Mana Cost,Muscle Experience Percent,Mysticality Experience Percent,Moxie Experience Percent,Minstrel Level,Muscle Limit,Mysticality Limit,Moxie Limit,Song Duration,Prismatic Damage,Smithsness,Supercold Resistance,Reduce Enemy Defense,Pool Skill,Surgeonosity];


boolean [monster] __genie_invalid_monsters = $monsters[ninja snowman assassin,modern zmobie,big swarm of ghuol whelps,giant swarm of ghuol whelps,swarm of ghuol whelps,dirty old lihc,ghostly pickle factory worker,mouthless murmur,mrs. freeze,Slime Tube Monster,xiblaxian political prisoner,snakefire in the grass,Spant soldier,BRICKO cathedral,BRICKO airship,giant amorphous blob,amorphous blob,"Blofeld",Thanksgolem,time-spinner prank,boneless blobghost,Source Agent,One Thousand Source Agents,giant rubber spider,skulldozer,your butt,Clara,Jick's butt,Brick Mulligan\, the Bartender,Trophyfish,Drunk cowpoke,Wannabe gunslinger,Surly gambler,Cow cultist,Hired gun,Camp cook,Skeletal gunslinger,Restless ghost,Buzzard,Mountain lion,Grizzled bear,Diamondback rattler,Coal snake,Frontwinder,Caugr,Pyrobove,Spidercow,Moomy,Jeff the Fancy Skeleton,Daisy the Unclean,Pecos Dave,Pharaoh Amoon-Ra Cowtep,Snake-Eyes Glenn,Former Sheriff Dan Driscoll,Unusual construct,Granny Hackleton,Villainous Minion,Villainous Henchperson,Villainous Villain,LOV Enforcer,LOV Engineer,LOV Equivocator,Abcrusher 4000&trade;,All-Hallow's Steve,Apathetic lizardman,Aquaconda,Baron von Ratsworth,Beast with X Ears,Beast with X Eyes,Bee swarm,Bee thoven,Beebee gunners,Beebee King,Beebee queue,Beelephant,Best Game Ever,Biclops,Black pudding,Bonerdagon,Book of Faces,Booty crab,BRICKO elephant,BRICKO gargantuchicken,BRICKO octopus,BRICKO oyster,BRICKO python,BRICKO turtle,BRICKO vacuum cleaner,Broodling seal,Brutus\, the toga-clad lout,Bugbear Captain,Bugbear robo-surgeon,Buzzerker,C.A.R.N.I.V.O.R.E. Operative,Candied Yam Golem,Canned goblin conspirator,Carbuncle Top,Carnivorous dill plant,Caveman Dan,Centurion of Sparky,Chatty coworker,Chester,Chief Electronic Overseer,Chocolate hare,Chocolate-cherry prairie dog,Cosmetics wraith,Count Drunkula,Count Drunkula (Hard Mode),Crazy bastard,Croqueteer,Cyrus the Virus,Danglin' Chad,Deadly Hydra,Demon of New Wave,Disorganized files,Dr. Awkward,Drownedbeat,Drunken rat king,E.V.E.\, the robot zombie,Ed the Undying,Elp&iacute;zo & Crosybdis,Endless conference call,Enormous blob of gray goo,Escalatormaster&trade;,Essence of Interspecies Respect,Essence of Soy,Essence of Tofu,Evil spaghetti cult assassin,Extremely annoyed witch,Falls-From-Sky,Falls-From-Sky (Hard Mode),Family of kobolds,Father McGruber,Father Nikolai Ravonovich,Fear Man,Fearsome giant squid,Fearsome Wacken,Felonia\, Queen of the Spooky Gravy Fairies,Ferocious roc,Filthworm drone,Filthworm royal guard,Fire truck,Fnord the Unspeakable,Frank &quot;Skipper&quot; Dan\, the Accordion Lord,Frosty,Frozen Solid Snake,Full-length mirror,Georgepaul\, the Balldodger,Ghost of Elizabeth Spookyraven,Ghost of Fernswarthy's Grandfather,Ghostly pickle factory worker,Giant bird-creature,Giant jungle python,Giant man-eating shark,Giant sandworm,Giant tardigrade,Gingerbread lawyer,Glass of Orange Juice,Goblin conspirator,Gorgolok\, the Demonic Hellseal,Great Wolf of the Air,Great Wolf of the Air (Hard Mode),Groar,Guajolote Cad&aacute;ver,Guard turtle,Gummi plesiosaur,Gurgle,Guy Made Of Bees,Hammered Yam Golem,Hank North\, Photojournalist,Heat seal,Heimandatz\, Nacho Golem,Hermetic seal,The Hermit,Hideous slide show,Hodgman\, The Hoboverlord,Holographic army,Hot bugbear,Hot ghost,Hot skeleton,Hot vampire,Hot werewolf,Hot zombie,Huge ghuol,Hunting seal,Ice cream truck,Inebriated Tofurkey,Jocko Homo,Johnringo\, the Netdragger,Knob Goblin King,Knott Slanding,Largish blob of gray goo,Larry of the Field of Signs,Larval filthworm,Legal alien,Legstrong&trade; stationary bicycle,Little blob of gray goo,Lord Spookyraven,Lumpy\, the Demonic Sauceblob,Malevolent Tofurkey,Mayor Ghost,Mayor Ghost (Hard Mode),Mimic,Moister oyster,Moneybee,Monty Basingstoke-Pratt\, IV,Mumblebee,Naughty Sorceress,Neil,Next-generation Frat Boy,Novia Cad&aacute;ver,Novio Cad&aacute;ver,Ol' Scratch,Oscus,your overflowing inbox,Padre Cad&aacute;ver,Panicking Knott Yeti,Peanut,Peregrino Cad&aacute;ver,Persona Inocente Cad&aacute;ver,Plastered Can of Cranberry Sauce,Monstrous Boiler,Possessed Can of Cranberry Sauce,Procedurally-generated skeleton,Professor Jacking,Protector Spectre,Queen Bee,Queen filthworm,Rack of free weights,Rock Pop weasel,Rotten dolphin thief,Sentient ATM,Your Shadow,Skelter Butleton\, the Butler Skeleton,Skulldozer,Slow Talkin' Elliot,Smut orc pervert,Snapdragon,Somebody else's butt,Somerset Lopez\, Demon Mariachi,Soused Stuffing Golem,Space beast matriarch,Space beast,Spaghetti Demon,Spawn of Wally,Spider conspirator,Spider-goblin conspirator,Spider-legged witch's hut,Spirit alarm clock,Stella\, the Demonic Turtle Poacher,Storm cow,Stuffing Golem,Tedious spreadsheet,The Big Wisniewski,Crimbomega,The Krampus,The Landscaper,The Man,The Nuge,The Server,The Sierpinski brothers,The Temporal Bandit,The Unkillable Skeleton,The Unkillable Skeleton (Hard Mode),Tiger-lily,Time-spinner prank,Tin can conspirator,Tin spider conspirator,Tomb rat king,Tome of Tropes,Totally Malicious 'Zine,Treadmill,Tio Cad&aacute;ver,Unearthed monstrosity,Unoptimized database,Vanya's Creature,Victor the Insult Comic Hellhound,Vine gar,War Frat Streaker,Wasp in a wig,Water cooler,White Bone Demon,Wu Tang the Betrayer,Wumpus,X Bottles of Beer on a Golem,X Stone Golem,X-dimensional horror,X-headed Hydra,Xiblaxian political prisoner,Your Brain,Zim Merman,Zombie Homeowners' Association,Zombie Homeowners' Association (Hard Mode),Zombo,7-Foot Dwarf (Moiling),7-Foot Dwarf (Royale),<s>Killer</s> Festive Arc-Welding Elfbot,<s>Killer</s> Festive Decal-Applying Elfbot,<s>Killer</s> Festive Laser-Calibrating Elfbot,<s>Killer</s> Festive Weapons-Assembly Elfbot,Underworld Tree,Accountant-Barbarian,Acoustic electric eel,Alien,Alien queen,Alien UFO,Aquabat,Aquagoblin,Auqadargon,Big Wisnaqua,Boss Bat,Boss Bat?,Dad Sea Monkee,Donerbagon,Dr. Aquard,Ed the Undying (1),Ed the Undying (2),Ed the Undying (3),Ed the Undying (4),Ed the Undying (5),Ed the Undying (6),Ed the Undying (7),gingerbread vigilante,Gorgolok\, the Infernal Seal (Inner Sanctum),Gorgolok\, the Infernal Seal (The Nemesis' Lair),Gorgolok\, the Infernal Seal (Volcanic Cave),hulking bridge troll,Lord Soggyraven,Lumpy\, the Sinister Sauceblob (Inner Sanctum),Lumpy\, the Sinister Sauceblob (The Nemesis' Lair),Lumpy\, the Sinister Sauceblob (Volcanic Cave),Mammon the Elephant,Naughty Sorceress (2),Naughty Sorceress (3),new Knob Goblin King,Protector Spurt,Shub-Jigguwatt\, Elder God of Violence,Somerset Lopez\, Dread Mariachi (Inner Sanctum),Somerset Lopez\, Dread Mariachi (The Nemesis' Lair),Somerset Lopez\, Dread Mariachi (Volcanic Cave),Spaghetti Elemental (Inner Sanctum),Spaghetti Elemental (The Nemesis' Lair),Spaghetti Elemental (Volcanic Cave),Spirit of New Wave (Inner Sanctum),Spirit of New Wave (The Nemesis' Lair),Spirit of New Wave (Volcanic Cave),Stella\, the Turtle Poacher (Inner Sanctum),Stella\, the Turtle Poacher (The Nemesis' Lair),Stella\, the Turtle Poacher (Volcanic Cave),The Aquaman,The Avatar of Sneaky Pete,The Bat in the Spats,The Clownlord Beelzebozo,The Large-Bellied Snitch,The Rain King,The Silent Nightmare,The Terrible Pinch,The Thing with No Name,The Thorax,Thug 1 and Thug 2,Yog-Urt\, Elder Goddess of Hatred,You the Adventurer,Your winged yeti,The Abominable Fudgeman,The Author,Kudzu,Mansquito,Miss Graves,The Plumber,The Mad Libber,Doc Clock,Mr. Burns,The Inquisitor,ancient protector spirit (The Hidden Apartment Building),ancient protector spirit (The Hidden Bowling Alley),ancient protector spirit (The Hidden Hospital),ancient protector spirit (The Hidden Office Building),Argarggagarg the Dire Hellseal,Ringogeorge\, the Bladeswitcher,Ron "The Weasel" Copperhead,Scott the Miner,Seannery the Conman,The Avatar of Boris,The Avatar of Jarlsberg,The Barrelmech of Diogenes,The Beefhemoth,The Colollilossus,The Cray-Kin,the Crimborg,the darkness (blind),The Emperor,the former owner of the Skeleton Store,The Frattlesnake,The Free Man,The Fudge Wizard,The ghost of Ebenoozer Screege,The ghost of Jim Unfortunato,The ghost of Lord Montague Spookyraven,the ghost of Monsieur Baguelle,the ghost of Oily McBindle,the ghost of Phil Bunion,The ghost of Richard Cockingham,The ghost of Sam McGee,The ghost of Vanillica "Trashblossom" Gorton,The ghost of Waldo the Carpathian,the gunk,The Headless Horseman,The Icewoman,The Jokester,The Lavalier,The Luter,The Mariachi With No Name,The Master of Thieves,The Mastermind,the most embarrassing moment in your entire life,the realization that everyone you love will die someday,The Sagittarian,The Snake With Like Ten Heads,The Unknown Accordion Thief,The Unknown Disco Bandit,The Unknown Pastamancer,The Unknown Sauceror,The Unknown Seal Clubber,The Unknown Turtle Tamer,The Whole Kingdom,Yakisoba the Executioner,the abstract concept of poverty,ancient protector spirit, ancient protector spirit (obsolete),Angry Space Marine,Norville Rogers,Norville Rogers,Peacannon,Herman East\, Relivinator,Angry Space Marine,Deputy Nick Soames & Earl,Charity the Zombie Hunter,Special Agent Wallace Burke Corrigan,Rag-tag band of survivors,Wesley J. "Wes" Campbell,Zombie-huntin' feller,Burning Snake of Fire,CDMoyer's butt,Hotstuff's Butt,Mr Skullhead's butt,Multi Czar's butt,Don Crimbo,intelligent alien,Kleptobrainiac,LOLmec,mayonnaise wasp,Cheetahman,Microwave Magus,Kung-Fu Hustler,Tasmanian Dervish,Macho Man,Iron Chef,Entire Shoplifter,Mr. Loathing,Metaphysical Gastronomist,Kleptobrainiac,Savage Beatnik,Creamweaver,Smooth Criminal,Fire Fighter,Cereal Arsonist,Burnglar,Grease Trapper,Ham Shaman,Porkpocket,Leonard,Ghostpuncher,Plague Chef,Batburglar,Arthur Frankenstein,Snowbrawler,Ice Cream Conjurer,Iceberglar,Granola Barbarian,Cheese Wizard,Assassin,Odorous Humongous,queen bee (Spelunky),small hostile animal,hostile plant,hostile intelligent alien,hostile plant,large hostile plant,exotic hostile plant,small hostile animal,large hostile animal,exotic hostile animal,Spant drone,Murderbot drone,Murderbot soldier,hostile intelligent alien,bat,cobra,snake,spider,bee,scorpion,skeleton,tikiman,caveman,yeti,crocodile man,cultist,magma man,mummy,devil,vampire,cobra,snake,spider,spider queen,skeleton,vampire,bee,mummy,Bananubis,Yomama,common criminal,uncommon criminal,rare criminal,low-level mook,vicious plant creature,vine-controlled botanist,low-level mook,giant leech,giant mosquito,low-level mook,lovestruck goth dude,walking skeleton,mid-level mook,liquid plumber,plumber's helper,mid-level mook,former inmate,former guard,mid-level mook,very [adjective] henchwoman,very [adjective] henchman,high-level mook,time bandit,clockwork man,high-level mook,serial arsonist,burner,high-level mook,inquisitee,trivia researcher,screambat];

boolean [effect] __genie_invalid_effects = $effects[jukebox hero,Juicy Boost,Meteor Showered,Steely-eyed squint,Blue Eyed Devil,Cereal Killer,Nearly All-Natural,Amazing,Throwing some shade,A rose by any other material,Gaze of the Gazelle,East of Eaten,Robot Friends,Smart Drunk,Margamergency,Pajama Party,Rumpel-Pumped,Song of Battle,Song of Solitude,Buy!\  Sell!\  Buy!\  Sell!,eldritch attunement,The Inquisitor's unknown effect,Filthworm Drone Stench,Filthworm Guard Stench,Filthworm Larva Stench,Green Peace,Red Menace,Video... Games?,things man was not meant to eat,Whitesloshed,thrice-cursed,bendin' hell,Synthesis: Hot,Synthesis: Cold,Synthesis: Pungent,Synthesis: Scary,Synthesis: Greasy,Synthesis: Strong,Synthesis: Smart,Synthesis: Cool,Synthesis: Hardy,Synthesis: Energy,Synthesis: Greed,Synthesis: Collection,Synthesis: Movement,Synthesis: Learning,Synthesis: Style,The Good Salmonella,Giant Growth,Lovebotamy,Open Heart Surgery,Wandering Eye Surgery,gar-ish,Puissant Pressure,Perspicacious Pressure,Pulchritudinous Pressure,It's Good To Be Royal!,The Fire Inside,Puzzle Champ,The Royal We,Hotform,Coldform,Sleazeform,Spookyform,Stenchform,A Hole in the World,Bored With Explosions,thanksgetting,Barrel of Laughs,Beer Barrel Polka,Superdrifting,Covetin' Drunk,All Wound Up,Driving Observantly,Driving Waterproofly,Bow-Legged Swagger,First Blood Kiwi,You've Got a Stew Going!,Shepherd's Breath,Of Course It Looks Great,Doing The Hustle,Fortune of the Wheel,Shelter of Shed,Hot Sweat,Cold Sweat,Rank Sweat,Black Sweat,Flop Sweat,Mark of Candy Cain,Black Day,What Are The Odds!?,Dancin' Drunk, School Spirited,Muffled,Sour Grapes,Song of Fortune,Pork Barrel,Ashen,Brooding,Purple Tongue,Green Tongue,Orange Tongue,Red Tongue,Blue Tongue,Black Tongue,Cupcake of Choice,The Cupcake of Wrath,Shiny Happy Cupcake,Your Cupcake Senses Are Tingling,Tiny Bubbles in the Cupcake,Broken Heart,Fiery Heart,Cold Hearted,Sweet Heart,Withered Heart,Lustful Heart,Pasta Eyeball,Cowlick,It's Ridiculous,Dangerous Zone Song,Tiffany's Breakfast,Flashy Dance Song,Pet Shop Song,Dark Orchestral Song,Bounty of Renenutet,Octolus Gift,Magnetized Ears,Lucky Struck,Drunk and Avuncular,Ministrations in the Dark,Record Hunger,SuperStar,Everything Looks Blue,Everything Looks Red,Everything Looks Yellow,Snow Fortified,Bubble Vision,High-Falutin',Song of Accompaniment,Song of Cockiness,Song of the Glorious Lunch,Song of the Southern Turtle,Song of Sauce,Song of Bravado,Song of Slowness,Song of Starch,Song of the North,It's a Good Life!,I'll Have the Soup,Why So Serious?,&quot;The Disease&quot;,Unmuffled,Overconfident,Shrieking Weasel,Biker Swagger,Punchable Face]; //'
//Works: Driving Wastefully, Driving Stealthily, rest untested

boolean [string] __genie_invalid_effect_strings = $strings[Double Negavision, Gettin' the Goods]; //because errors on older versions


int bestModForTableCount(int count)
{
	int best_mod = 3;
	int best_lines = -1;
	for i from 2 to 5
	{
		int lines = ceil(to_float(count) / to_float(i));
		if (lines < best_lines || best_lines == -1)
		{
			best_mod = i;
			best_lines = lines;
		}
		/*if (count % i == 0)
		{
			best_mod = i;
			best_lines = lines;
		}*/
	}
	return best_mod;
}

static
{
	monster [int] __genie_valid_monster_list_first_pass_monsters;
}

monster [int] genieGenerateValidMonsterList()
{
	monster [int] first_pass_monsters;
	if (__genie_valid_monster_list_first_pass_monsters.count() == 0)
	{
		foreach m in $monsters[]
		{
			if (m.boss)
				continue;
			if (m.attributes.contains_text("ULTRARARE")) continue;
			if (__genie_invalid_monsters[m]) continue;
			first_pass_monsters.listAppend(m);
		}
		sort first_pass_monsters by value.to_string().to_lower_case();
		__genie_valid_monster_list_first_pass_monsters = first_pass_monsters;
	}
	else
		first_pass_monsters = __genie_valid_monster_list_first_pass_monsters;
	
	//Now order monsters:
	monster [int] early_monster_order;
	
	if (!get_property("kingLiberated").to_boolean())
	{
		//FIXME most of these have quest tests, but some do not. and obviously, CS
		early_monster_order.listAppend($monster[ghost]);
		if (!QuestState("questM20Necklace").finished)
			early_monster_order.listAppend($monster[writing desk]);
		if (get_property("sidequestLighthouseCompleted") == "none" && !QuestState("questL12War").finished)
			early_monster_order.listAppend($monster[lobsterfrogman]);
		early_monster_order.listAppend($monster[Astronomer]);
		early_monster_order.listAppend($monster[Camel's Toe]); //'
		if (QuestState("questL08Trapper").mafia_internal_step < 3 && get_property_item("trapperOre").available_amount() < 3)
			early_monster_order.listAppend($monster[Mountain Man]);
		if ($item[talisman o' namsilat].available_amount() == 0) //'
			early_monster_order.listAppend($monster[gaudy pirate]);
		if (get_property_int("desertExploration") < 100 && $item[drum machine].available_amount() == 0) //FIXME the exact test is way more complicated
			early_monster_order.listAppend($monster[blur]);
		if (!have_outfit_components("Frat Warrior Fatigues") && !QuestState("questL12War").finished)
			early_monster_order.listAppend($monster[Orcish Frat Boy Spy]);
		if (QuestState("questL12War").mafia_internal_step == 2)
		{
			early_monster_order.listAppend($monster[green ops soldier]);
			if (get_property("sidequestNunsCompleted") == "none")
				early_monster_order.listAppend($monster[dirty thieving brigand]);
		}
		if ($items[antique machete,Machetito,Muculent machete,Papier-m&acirc;ch&eacute;te].available_amount() == 0) //FIXME test hidden properties
			early_monster_order.listAppend($monster[forest spirit]);
	}
	
	if (!$item[Witchess Set].is_unrestricted() || get_campground()[$item[Witchess Set]] == 0 || get_property_int("_witchessFights") >= 5)
	{
		//Add a few of them:
		if (fullness_limit() > 0)
			early_monster_order.listAppend($monster[Witchess Knight]);
		if (inebriety_limit() > 0)
			early_monster_order.listAppend($monster[Witchess Bishop]);
		early_monster_order.listAppend($monster[Witchess Rook]);
	}
	early_monster_order.listAppend($monster[black crayon crimbo elf]);
	
	
	
	
	
	monster [int] out;
	boolean [monster] out_monsters;
	
	foreach key, m in early_monster_order
	{
		if (out_monsters[m]) continue;
		out.listAppend(m);
		out_monsters[m] = true;
	}
	out.listAppend($monster[none]);
	
	
	foreach key, m in first_pass_monsters
	{
		if (out_monsters[m]) continue;
		out.listAppend(m);
		//out_monsters[m] = true;
	}
	
	return out;
}

boolean effectIsAvatarPotion(effect e)
{
	return e.string_modifier("Avatar") != "";
}

static
{
	boolean [effect] __genie_valid_effects;
	effect [int] __genie_valid_effect_list;
	effect [int] __genie_valid_avatar_potions;
}

boolean [effect] genieValidEffects()
{
	if (__genie_valid_effects.count() > 0)
		return __genie_valid_effects;
	
	boolean [effect] additional_invalid_effects;
	foreach s in __genie_invalid_effect_strings
	{
		effect e = s.to_effect();
		if (e != $effect[none])
			additional_invalid_effects[e] = true;
	}
	foreach e in $effects[]
	{
		if (__genie_invalid_effects contains e) continue;
		if (additional_invalid_effects contains e) continue;
		__genie_valid_effects[e] = true;
	}
	return __genie_valid_effects;
}

effect [int] genieGenerateValidEffectList()
{
	if (__genie_valid_effect_list.count() > 0)
		return __genie_valid_effect_list;
	
	effect [int] first_pass_effects;
	effect [int] second_pass_effects;
	foreach e in genieValidEffects()
	{
		if (e.effectIsAvatarPotion())
		{
			continue;
			//second_pass_effects.listAppend(e);
		}
		else
			first_pass_effects.listAppend(e);
	}
	sort first_pass_effects by value.to_string().to_lower_case();
	sort second_pass_effects by value.to_string().to_lower_case();
	
	effect [int] early_effect_order;
	early_effect_order.listAppend($effect[Frosty]);
	early_effect_order.listAppend($effect[sinuses for miles]);
	
	effect [int] out;
	boolean [effect] out_effects;
	
	foreach key, e in early_effect_order
	{
		if (out_effects[e]) continue;
		if (__genie_invalid_effects[e]) continue;
		out.listAppend(e);
		out_effects[e] = true;
	}
	out.listAppend($effect[none]);
	
	
	foreach key, e in first_pass_effects
	{
		if (out_effects[e]) continue;
		out.listAppend(e);
		out_effects[e] = true;
	}
	if (second_pass_effects.count() > 0)
	{
		out.listAppend($effect[none]);
		foreach key, e in second_pass_effects
		{
			if (out_effects[e]) continue;
			out.listAppend(e);
			out_effects[e] = true;
		}
	}	
	__genie_valid_effect_list = out;
	return out;
}

effect [int] genieGenerateValidAvatarList()
{
	if (__genie_valid_avatar_potions.count() > 0)
		return __genie_valid_avatar_potions;
	effect [int] out;
	foreach e in $effects[]
	{
		if (!e.effectIsAvatarPotion()) continue;
		out.listAppend(e);
	}
	sort out by value.string_modifier("Avatar");
	__genie_valid_avatar_potions = out;
	return out;
}

buffer generateSelectionDropdown(string [int] descriptions, string [int] ids, string [int] replacement_images, string selection_div_id)
{
	int text_limit = 50;
	buffer out;
	out.append("<select id=\"" + selection_div_id + "\" style=\"width:100%;\" onchange=\"genieSelectionChanged('" + selection_div_id + "');\">");
	out.append("<option value=\"-1\"></option>");
	foreach key in descriptions
	{
		out.append("<option value=\"");
		//out.append(ids[key].replace_string("\"", "\\\""));
		out.append(ids[key].entity_encode()); //replace_string("\"", "").
		out.append("\"");
		string replacement_image = replacement_images[key];
		if (replacement_image != "")
		{
			out.append(" data-replacement-image=\"");
			out.append(replacement_image);
			//out.append("images/otherimages/witchywoman.gif");
			out.append("\"");
		}
		out.append(">");
		
		string description = descriptions[key];
		
		if (description.length() >= text_limit)
			description = description.substring(0, text_limit - 1) + "...";
		out.append(description);
		out.append("</option>");
	}
	out.append("</select>");
	return out;
}

buffer generateButton(string text, string id, boolean make_table_cell, string command, string image)
{
	boolean use_divs = true;
	buffer out;
	
	boolean inline_image_cells = false; //make_table_cell && image != "";
	
	if (make_table_cell && !use_divs)
		out.append("<div style=\"display:table-cell;vertical-align:middle;\">");
	if (use_divs)
		out.append("<div");
	else
		out.append("<button");
	out.append(" style=\"");
	if (make_table_cell && !use_divs)
		out.append("width:100%;");
	if (make_table_cell && use_divs)
		out.append("display:table-cell;");
	else if (!make_table_cell)
		out.append("display:inline-block;");
	out.append("\" class=\"button\"");
	if (id != "")
	{
		out.append(" id=\"");
		out.append(id);
		out.append("\"");
	}
	out.append(" onmouseup=\"genieButtonClicked(");
	out.append("'");
	out.append(id);
	out.append("', '");
	out.append(command);
	out.append("', '");
	out.append(my_hash());
	out.append("'");
	
	out.append(");\"");
	if (command != "")
	{
		out.append(" title=\"");
		out.append(command.replace_string("\\", ""));
		out.append("\"");
	}
	out.append(">");
	
	if (image != "")
	{
		//margin-left:auto;margin-right:auto;
		if (!inline_image_cells)
			out.append("<div style=\"display:table;\"><div style=\"display:table-row;\">");
		out.append("<div style=\"display:table-cell;vertical-align:middle;\">");
		out.append("<img src=\"images/" + image + "\" style=\"mix-blend-mode:multiply;\" width=30 height=30>");
		out.append("</div><div style=\"display:table-cell;vertical-align:middle;padding-left:2px;\">");
	}
	out.append(text);
	if (image != "")
	{
		out.append("</div>");
		if (!inline_image_cells)
			out.append("</div></div>");
	}
	if (use_divs)
		out.append("</div>");
	else
		out.append("</button>");
	if (make_table_cell && !use_divs)
		out.append("</div>");
	return out;
}
buffer generateButton(string text, string id, boolean make_table_cell, string command)
{
	return generateButton(text, id, make_table_cell, "", "");
}
buffer generateButton(string text, string id, boolean make_table_cell)
{
	return generateButton(text, id, make_table_cell, "");
}


string genericiseImageString(string image)
{
	return image.replace_string("https://s3.amazonaws.com/images.kingdomofloathing.com/", "");
}
string imageFromItem(item it)
{
	return genericiseImageString((it.image.contains_text("s3.amazon") ? "" : "itemimages/") + it.image);
}
string imageFromEffect(effect e)
{
	return genericiseImageString(e.image);
}
string imageFromMonster(monster m)
{
	return genericiseImageString((m.image.contains_text("s3.amazon") ? "" : "adventureimages/") + m.image);
}

boolean [string] __effect_descriptions_modifier_is_percent;
string [string] __effect_descriptions_modifier_short_description_mapping;

void initialiseGenieEffectDescriptions()
{
	__effect_descriptions_modifier_is_percent["item drop"] = true;
	__effect_descriptions_modifier_is_percent["booze drop"] = true;
	__effect_descriptions_modifier_is_percent["food drop"] = true;
	__effect_descriptions_modifier_is_percent["meat drop"] = true;
	__effect_descriptions_modifier_is_percent["initiative"] = true;
	__effect_descriptions_modifier_is_percent["combat rate"] = true;
	__effect_descriptions_modifier_short_description_mapping["item drop"] = "item";
	__effect_descriptions_modifier_short_description_mapping["meat drop"] = "meat";
	__effect_descriptions_modifier_short_description_mapping["combat rate"] = "combat";
	__effect_descriptions_modifier_short_description_mapping["initiative"] = "init";
}

static
{
	buffer [effect] __genie_saved_effect_descriptions;
}

initialiseGenieEffectDescriptions();
buffer genieGenerateEffectDescription(effect e)
{
	if (__genie_saved_effect_descriptions contains e) return __genie_saved_effect_descriptions[e];
	buffer out;
	out.append(e);
	boolean first = true;
	//foreach modifier in __numeric_modifier_names
	foreach modifier in __modifiers_for_effect[e]
	{
		float v = e.numeric_modifier(modifier);
		if (v == 0.0) continue;
		if (first)
		{
			out.append(" (");
			first = false;
		}
		else
		{
			out.append(",");
		}
		if (v > 0)
			out.append("+");
		out.append(v.round());
		if (__effect_descriptions_modifier_is_percent[modifier] || modifier.contains_text("Percent"))
			out.append("%");
		out.append(" ");
		if (__effect_descriptions_modifier_short_description_mapping contains modifier)
			out.append(__effect_descriptions_modifier_short_description_mapping[modifier]);
		else
		{
			string description = modifier;
			if (description.contains_text(" Percent"))
				description = description.replace_string(" Percent", "");
			if (description.contains_text("Mysticality"))
				description = description.replace_string("Mysticality", " Myst");
			if (description.contains_text("Maximum "))
				description = description.replace_string("Maximum ", "");
			if (description.contains_text("Resistance"))
				description = description.replace_string("Resistance", "res");
			if (description.contains_text("Damage"))
				description = description.replace_string("Damage", "dmg");
			
			description = description.to_lower_case();
			out.append(description);
		}
	}
	if (!first)
		out.append(")");
	if (!__effect_contains_non_constant_modifiers[e]) //always regenerate dynamic effects
		__genie_saved_effect_descriptions[e] = out;
	return out;
}

buffer genieGenerateDropdowns()
{
	buffer out;
	out.append("<div style=\"display:table;width:100%;\"><div style=\"display:table-row;\">");
	
	if (get_property_int("_genieFightsUsed") < 3)
	{
		out.append("<div style=\"display:table-cell;\">To fight a</div>");
	
		out.append("<div style=\"display:table-cell;\">");
		string [int] monster_descriptions;
		string [int] monster_ids;
		string [int] monster_replacement_images;
		foreach key, m in genieGenerateValidMonsterList()
		{
			if (m == $monster[none])
				monster_descriptions[key] = "-------------";
			else
				monster_descriptions[key] = m;
			//monster_ids[key] = m.manuel_name.replace_string("\"", "&quot;");
			monster_ids[key] = m.manuel_name.replace_string("\"", "\\\"");
		
			string image = "images/" + imageFromMonster(m);
			if (m != $monster[none])
				monster_replacement_images[key] = image;
		}
		out.append(generateSelectionDropdown(monster_descriptions, monster_ids, monster_replacement_images, "monster_selection_div"));
		out.append("</div><div style=\"display:table-cell;\">");
		out.append(generateButton("Go", "monster_selection_button", false));
		out.append("</div></div><div style=\"display:table-row\">");
	}
	
	string [int] effect_descriptions;
	string [int] effect_ids;
	string [int] blank;
	foreach key, e in genieGenerateValidEffectList()
	{
		if (e == $effect[none])
			effect_descriptions[key] = "-------------";
		else
			effect_descriptions[key] = genieGenerateEffectDescription(e);
		effect_ids[key] = e;
	}
	
	out.append("<div style=\"display:table-cell;padding-right:5px;\">For twenty turns of</div>");
	out.append("<div style=\"display:table-cell;\">");
	out.append(generateSelectionDropdown(effect_descriptions, effect_ids, blank, "effect_selection_div"));
	out.append("</div><div style=\"display:table-cell;\">");
	out.append(generateButton("Go", "effect_selection_button", false));
	out.append("</div></div><div style=\"display:table-row\">");
	
	string [int] avatar_descriptions;
	string [int] avatar_ids;
	string [int] avatar_replacement_images;
	foreach key, e in genieGenerateValidAvatarList()
	{
		if (e == $effect[none])
			avatar_descriptions[key] = "-------------";
		else
			avatar_descriptions[key] = e.string_modifier("Avatar");
		avatar_ids[key] = e;
		
		monster m = e.string_modifier("Avatar").to_monster();
		if (m != $monster[none])
		{
			string image = "images/" + imageFromMonster(m);
			avatar_replacement_images[key] = image;
		}
	}
	out.append("<div style=\"display:table-cell;\">To look like a </div>");
	out.append("<div style=\"display:table-cell;\">");
	out.append(generateSelectionDropdown(avatar_descriptions, avatar_ids, avatar_replacement_images, "avatar_selection_div"));
	out.append("</div><div style=\"display:table-cell;\">");
	out.append(generateButton("Go", "avatar_selection_button", false));
	out.append("</div>");
	
	out.append("</div></div>");
	return out;
}

buffer genieGenerateHardcodedWishes()
{
	buffer out;
	//Hardcoded wishes:
	out.append("<div style=\"display:table;width:100%;\"><div style=\"display:table-row;\">");
	
	out.append(generateButton(MIN(50000, my_level() * 500) + " meat", "be_rich_button", true, "for more meat", "itemimages/meat.gif"));
	out.append(generateButton("A pony", "pony_button", true, "for a pony", "itemimages/pony1.gif"));
	out.append(generateButton("All stats", "all_stats_button", true, "I were big", "itemimages/dna.gif"));
	out.append("</div><div style=\"display:table-row;\">");
	
	/*string mainstat_wish;
	if (my_primestat() == $stat[muscle])
		mainstat_wish = "I was taller";
	else if (my_primestat() == $stat[mysticality])
		mainstat_wish = "I wish I had a rabbit in a hat with a bat";
	else if (my_primestat() == $stat[moxie])
		mainstat_wish = "I was a baller";
	if (mainstat_wish != "")
		out.append(generateButton("Mainstat", "mainstat_button", true, mainstat_wish));*/
	out.append(generateButton("Muscle stats", "muscle_button", true, "I was a little bit taller", "itemimages/bigdumbbell.gif"));
	out.append(generateButton("Mysticality stats", "mysticality_button", true, "I wish I had a rabbit in a hat with a bat", "itemimages/tinystars.gif"));
	out.append(generateButton("Moxie stats", "moxie_button", true, "I was a baller", "itemimages/greaserint.gif"));
	out.append("</div><div style=\"display:table-row;\">");
	out.append(generateButton("Pocket wish", "pocket_wish_button", true, "for more wishes", "itemimages/whitecard.gif"));
	out.append(generateButton("Fight the genie", "genie_button", true, "you were free", "itemimages/gbottle_open.gif"));
	if (to_item("blessed rustproof +2 gray dragon scale mail").available_amount() == 0)
		out.append(generateButton("Dragon mail", "", true, "for a blessed rustproof +2 gray dragon scale mail", "itemimages/envelope.gif"));
	//blessed rustproof +2 gray dragon scale mail
	//FIXME got milk, ode to booze, etc
	out.append("</div>"); //table-row
	out.append("</div>"); //table
	
	return out;
}

Record GenieBestEffectResult
{
	effect e;
	float value;
};

Record GenieScoreValueResult
{
	float score;
	float value;
};

GenieScoreValueResult genieScoreAndValueForEffect(boolean [string] modifiers, effect e, boolean maximum_minimum)
{
	float value = 0.0; //FIXME muscle/myst/etc
	
	boolean first = true;
	foreach modifier in modifiers
	{
		//if (!__modifiers_for_effect[e][modifier]) continue;
		float modifier_value = e.numeric_modifier(modifier);
		boolean skip = false;
		foreach e2 in $elements[hot,stench,spooky,cold,sleaze]
		{
			string flat_damage_lookup = e2 + " Damage";
			string spell_damage_lookup = e2 + " Spell Damage";
			if (maximum_minimum && modifiers[flat_damage_lookup] && modifiers[spell_damage_lookup])
			{
				if (modifier == flat_damage_lookup)
				{
					modifier_value += e.numeric_modifier(spell_damage_lookup);
				}
				else if (modifier == spell_damage_lookup)
				{
					skip = true;
					break;
				}
			}
		}
		if (skip)
			continue;
		if (maximum_minimum)
		{
			if (first)
				value = modifier_value;
			else
				value = MIN(value, modifier_value);
		}
		else
			value += modifier_value;
		first = false;
	}
	
	float tiebreaker_score = 0.0;
	foreach s in $strings[Item Drop,Meat Drop]
	{
		if (modifiers[s]) continue;
		tiebreaker_score += e.numeric_modifier(s) / 10000.0;
	}
	foreach s in $strings[HP Regen Max,Muscle,Mysticality,Moxie]
		tiebreaker_score += e.numeric_modifier(s) * 0.00000000001; //tiebreak why not.
	if (modifiers["muscle percent"] || modifiers["mysticality percent"] || modifiers["moxie percent"])
	{
		foreach s in $strings[muscle percent,mysticality percent,moxie percent]
		{
			if (!modifiers[s])
			{
				tiebreaker_score += e.numeric_modifier(s) / 10000.0;
			}
		}
	}
	
	float score = value + MAX(-1.0, MIN(1.0, tiebreaker_score));
	GenieScoreValueResult result;
	result.score = score;
	result.value = value;
	return result;
}

GenieBestEffectResult findBestEffectForModifiers(boolean [string] modifiers_in, boolean should_be_negative, boolean [effect] effects_we_can_obtain_otherwise, boolean [effect] valid_effects, boolean maximum_minimum)
{
	boolean [string] modifiers;
	foreach modifier in modifiers_in
		modifiers[modifier.to_lower_case()] = modifiers_in[modifier];
	float best_effect_score = 0.0;
	float best_effect_value = 0.0;
	effect best_effect = $effect[none];
	
	
	//foreach e in valid_effects
	foreach m in modifiers
	{
		foreach e in __effects_for_modifiers[m]
		{
			if (effects_we_can_obtain_otherwise[e]) continue;
			if (!valid_effects[e]) continue;
			if (!e.effect_is_usable()) continue;
			/*boolean relevant = false;
			foreach modifier in modifiers
			{
				if (__modifiers_for_effect[e][modifier])
				{
					relevant = true;
				}
			}
			if (!relevant)
				continue;*/
			if (e.have_effect() > 0) continue;
		
			GenieScoreValueResult score_and_value = genieScoreAndValueForEffect(modifiers, e, maximum_minimum);
			float score = score_and_value.score;
			float value = score_and_value.value;
			if (should_be_negative)
			{
				if (score < best_effect_score)
				{
					best_effect_score = score;
					best_effect_value = value;
					best_effect = e;
				}
			}
			else if (score > best_effect_score)
			{
				best_effect_score = score;
				best_effect_value = value;
				best_effect = e;
			}
		}
	}
	GenieBestEffectResult result;
	result.e = best_effect;
	result.value = best_effect_value;
	return result;
}

buffer genieGenerateNextEffectWishes()
{
	buffer out;
	
	Record ModifierButtonEntry
	{
		string display_name;
		boolean [string] modifiers;
		int set;
		boolean is_percent;
		string image;
		boolean maximum_minimum;
	};
	ModifierButtonEntry ModifierButtonEntryMake(string display_name, boolean [string] modifiers, int set, boolean is_percent, string image)
	{
		ModifierButtonEntry entry;
		entry.display_name = display_name;
		entry.modifiers = modifiers;
		entry.set = set;
		entry.is_percent = is_percent;
		entry.image = image;
		return entry;
	}
	ModifierButtonEntry ModifierButtonEntryMake(string display_name, string modifier, int set, boolean is_percent, string image)
	{
		boolean [string] modifiers;
		modifiers[modifier] = true;
		return ModifierButtonEntryMake(display_name, modifiers, set, is_percent, image);
	}
	void listAppend(ModifierButtonEntry [int] list, ModifierButtonEntry entry)
	{
		int position = list.count();
		while (list contains position)
			position += 1;
		list[position] = entry;
	}
	
	boolean [effect] valid_effects = genieValidEffects();
	
	
	
	boolean [effect] effects_we_can_obtain_otherwise;
	foreach s in $skills[]
	{
		effect e = s.to_effect();
		if (e == $effect[none]) continue;
		if (s.skill_is_usable() && s.mp_cost() <= my_maxmp())
			effects_we_can_obtain_otherwise[e] = true;
	}
	if (!can_interact())
	{
		foreach it in $items[]
		{
			if (it.available_amount() == 0) continue;
			if (it.inebriety + it.spleen + it.fullness > 0) continue;
			effect e = it.to_effect();
			if (e == $effect[none]) continue;
			effects_we_can_obtain_otherwise[e] = true;
		}
	}
	
	
	
	//Modifiers:
	ModifierButtonEntry [int] modifier_buttons;
	//string [string] modifier_buttons; //description -> numeric_modifier
	
	modifier_buttons.listAppend(ModifierButtonEntryMake("meat", "Meat Drop", 0, true, "itemimages/meat.gif"));
	modifier_buttons.listAppend(ModifierButtonEntryMake("item", "Item Drop", 0, true, "itemimages/potion9.gif"));
	
	GenieBestEffectResult best_effect_result_muscle = findBestEffectForModifiers($strings[muscle percent], false, effects_we_can_obtain_otherwise, valid_effects, false);
	GenieBestEffectResult best_effect_result_mysticality = findBestEffectForModifiers($strings[mysticality percent], false, effects_we_can_obtain_otherwise, valid_effects, false);
	GenieBestEffectResult best_effect_result_moxie = findBestEffectForModifiers($strings[moxie percent], false, effects_we_can_obtain_otherwise, valid_effects, false);
	
	if (best_effect_result_muscle.e == best_effect_result_mysticality.e && best_effect_result_muscle.e == best_effect_result_moxie.e)
	{
		modifier_buttons.listAppend(ModifierButtonEntryMake("all stats", "muscle percent", 1, true, "itemimages/dna.gif"));
	}
	else
	{
		modifier_buttons.listAppend(ModifierButtonEntryMake("muscle", "muscle percent", 1, true, "itemimages/bigdumbbell.gif"));
		modifier_buttons.listAppend(ModifierButtonEntryMake("mysticality", "mysticality percent", 1, true, "itemimages/tinystars.gif"));
		modifier_buttons.listAppend(ModifierButtonEntryMake("moxie", "moxie percent", 1, true, "itemimages/greaserint.gif"));
	}


	modifier_buttons.listAppend(ModifierButtonEntryMake("+combat", "combat rate", 0, true, "itemimages/familiar14.gif"));
	modifier_buttons.listAppend(ModifierButtonEntryMake("combat", "combat rate", 0, true, "itemimages/footprints.gif"));
	if (my_familiar() != $familiar[none])
		modifier_buttons.listAppend(ModifierButtonEntryMake("familiar weight", "familiar weight", 0, false, "itemimages/blackcat.gif"));
	modifier_buttons.listAppend(ModifierButtonEntryMake("init", "initiative", 0, true, "itemimages/fast.gif"));
	modifier_buttons.listAppend(ModifierButtonEntryMake("ML", "Monster Level", 0, false, "itemimages/skinknife.gif"));
	
	boolean [string] prismatic_damage_modifiers;
	foreach e in $elements[hot,stench,spooky,cold,sleaze]
	{
		prismatic_damage_modifiers[e + " Damage"] = true;
		prismatic_damage_modifiers[e + " Spell Damage"] = true;
	}
	modifier_buttons.listAppend(ModifierButtonEntryMake("Prismatic dmg", prismatic_damage_modifiers, 0, false, "itemimages/rrainbow.gif"));
	modifier_buttons[modifier_buttons.count() - 1].maximum_minimum = true;
	modifier_buttons.listAppend(ModifierButtonEntryMake("HP", "Maximum HP Percent", 1, true, "itemimages/strboost.gif"));
	modifier_buttons.listAppend(ModifierButtonEntryMake("HP", "Maximum HP", 1, false, "itemimages/strboost.gif"));
	if (my_primestat() == $stat[muscle])
		modifier_buttons.listAppend(ModifierButtonEntryMake("mainstat exp", "muscle experience percent", 1, true, "itemimages/fitposter.gif"));
	else if (my_primestat() == $stat[mysticality])
		modifier_buttons.listAppend(ModifierButtonEntryMake("mainstat exp", "mysticality experience percent", 1, true, "itemimages/fitposter.gif"));
	else if (my_primestat() == $stat[moxie])
		modifier_buttons.listAppend(ModifierButtonEntryMake("mainstat exp", "moxie experience percent", 1, true, "itemimages/fitposter.gif"));
	
	string [element] image_for_element = {$element[cold]:"itemimages/snowflake.gif", $element[stench]:"itemimages/stench.gif", $element[hot]:"itemimages/flame.gif", $element[spooky]:"itemimages/skull.gif", $element[sleaze]:"itemimages/wink.gif"};
	
	string [element] colour_for_element = {$element[cold]:"blue", $element[stench]:"green", $element[hot]:"red", $element[spooky]:"gray", $element[sleaze]:"purple"};
	foreach e in $elements[hot,stench,spooky,cold,sleaze]
	{
		string colour_span = "<span style=\"color:" + colour_for_element[e] + ";\">";
		modifier_buttons.listAppend(ModifierButtonEntryMake(colour_span + e + " res</span>", e + " Resistance", 2, false, image_for_element[e]));
		boolean [string] damage_modifiers;
		damage_modifiers[e + " Damage"] = true;
		damage_modifiers[e + " Spell Damage"] = true;
		modifier_buttons.listAppend(ModifierButtonEntryMake(colour_span + e + " dmg</span>", damage_modifiers, 3, false, image_for_element[e]));
	}
	modifier_buttons.listAppend(ModifierButtonEntryMake("food drop", "Food Drop", 4, true, "itemimages/bowl.gif"));
	modifier_buttons.listAppend(ModifierButtonEntryMake("booze drop", "Booze Drop", 4, true, "itemimages/tankard.gif"));
	modifier_buttons.listAppend(ModifierButtonEntryMake("damage", "Weapon Damage Percent", 4, true, "itemimages/nicesword.gif"));
	modifier_buttons.listAppend(ModifierButtonEntryMake("spell damage", "Spell Damage Percent", 4, true, "itemimages/wizhat2.gif"));
	

	if (true)
	{
		modifier_buttons.listAppend(ModifierButtonEntryMake("muscle", "muscle", 1, false, "itemimages/bigdumbbell.gif"));
		modifier_buttons.listAppend(ModifierButtonEntryMake("mysticality", "mysticality", 1, false, "itemimages/tinystars.gif"));
		modifier_buttons.listAppend(ModifierButtonEntryMake("moxie", "moxie", 1, false, "itemimages/greaserint.gif"));
		modifier_buttons.listAppend(ModifierButtonEntryMake("DA", "damage absorption", 1, false, "itemimages/wallshield.gif"));
	}
	
	//Community service:
	//melee damage percent
	//spell damage percent
	//booze drops
	//hot resistance
	//out.append("<div class=\"genie_header\">Buffs</div>");
	out.append("<div style=\"display:table;width:100%;\"><div style=\"display:table-row;\">");
	int buttons_written = 0;
	
	sort modifier_buttons by value.set;
	int [int] entries_per_set;
	foreach key, entry in modifier_buttons
	{
		entries_per_set[entry.set] = entries_per_set[entry.set] + 1;
	}
	//foreach description, modifier in modifier_buttons
	int last_set = 0;
	foreach key, entry in modifier_buttons
	{
		if (entry.set != last_set)
		{
			buttons_written = 0;
			last_set = entry.set;
			out.append("</div></div>");
			out.append("<hr>");
			out.append("<div style=\"display:table;width:100%;\"><div style=\"display:table-row;\">");
		}
		
		boolean is_percent = entry.is_percent;
		boolean should_be_negative = false;
		if (entry.display_name == "combat")
			should_be_negative = true;
		/*if (entry.display_name == "familiar weight" || entry.display_name == "ML")
			is_percent = false;*/
		GenieBestEffectResult best_effect_result = findBestEffectForModifiers(entry.modifiers, should_be_negative, effects_we_can_obtain_otherwise, valid_effects, entry.maximum_minimum);
		
		if (best_effect_result.e == $effect[none]) continue;
		//print_html(entry.display_name + ": " + best_effect);

		if (buttons_written % bestModForTableCount(entries_per_set[entry.set]) == 0 && buttons_written > 0)
			out.append("</div><div style=\"display:table-row;\">");
		int amount = best_effect_result.value;
		string wish = "to be " + best_effect_result.e.replace_string("'", "\\'").entity_encode();
		
		string image = imageFromEffect(best_effect_result.e);
		if (entry.image != "")
			image = entry.image;
		
		out.append(generateButton((amount > 0 ? "+" : "") + amount + (is_percent ? "% " : " ") + entry.display_name, "", true, wish, image));
		buttons_written += 1;
	}
	out.append("</div>"); //table-row
	out.append("</div>"); //table
	return out;
}

buffer genieGenerateSecondaryHardcodedWishes()
{
	//Got Milk, Ode to Booze, Super Skill, Fishy, etc.
	buffer out;
	
	
	string [effect] effect_descriptions;
	
	boolean [effect] desired_effects;
	if (fullness_limit() - my_fullness() > 0)
	{
		if ($item[milk of magnesium].available_amount() == 0) //'
			desired_effects[$effect[got milk]] = true;
		//desired_effects[$effect[Barrel of Laughs]] = true;
		//effect_descriptions[$effect[Barrel of Laughs]] = "+4 adv from food";
		//FIXME The Tunger™ (probably not)
	}
	if (inebriety_limit() - my_inebriety() >= 0)
	{
		if (!$skill[the ode to booze].skill_is_usable())
			desired_effects[$effect[ode to booze]] = true;
		//desired_effects[$effect[Beer Barrel Polka]] = true;
		//effect_descriptions[$effect[Beer Barrel Polka]] = "+4 adv from booze";
	}
	if (!($skill[Inigo's Incantation of Inspiration].skill_is_usable() && $skill[Inigo's Incantation of Inspiration].is_unrestricted() && $effect[Inigo's Incantation of Inspiration].have_effect() == 0)) //'
		desired_effects[$effect[Inigo's Incantation of Inspiration]] = true; //'
	effect_descriptions[$effect[Inigo's Incantation of Inspiration]] = "craft for free"; //'
	
	
	desired_effects[$effect[super skill]] = true;
	effect_descriptions[$effect[super skill]] = "0MP skills";
	
	if (get_property_int("desertExploration") > 0 && get_property_int("desertExploration") < 100)
		desired_effects[$effect[ultrahydrated]] = true;
	
	desired_effects[$effect[Fishy]] = true;
	
	if ($item[cold one].available_amount() > 0 && inebriety_limit() - my_inebriety() > 0)
	{
		desired_effects[$effect[Salty Mouth]] = true;
		effect_descriptions[$effect[Salty Mouth]] = "+5 adv from Cold One/beer";
	}
	out.append("<hr>");
	int buttons_shown = 0;
	out.append("<div style=\"display:table;width:100%;\"><div style=\"display:table-row;\">");
	
	boolean [effect] effects_showing;
	foreach e in desired_effects
	{
		if (e.have_effect() > 0) continue;
		effects_showing[e] = true;
	}
	foreach e in effects_showing
	{
		if (buttons_shown % bestModForTableCount(effects_showing.count()) == 0 && buttons_shown > 0)
			out.append("</div><div style=\"display:table-row;\">");
		
		string button_description = e;
		button_description += "<br>";
		if (effect_descriptions contains e)
			button_description += "<span style=\"font-weight:normal;font-size:0.9em;\">(" + effect_descriptions[e] + ")</span>";
		string wish = "to be " + e.replace_string("'", "\\'").entity_encode();
		out.append(generateButton(button_description, "", true, wish, imageFromEffect(e)));
		buttons_shown += 1;
	}
	out.append("</div></div>");
	return out;
}

buffer genieGenerateText()
{
	buffer out;
	out.append("<script type=\"text/javascript\" src=\"genie.js\"></script>");
	out.append("<style type=\"text/css\">");
	//out.append("div.button {border: 2px black solid;font-family: Arial, Helvetica, sans-serif;font-size: 10pt;font-weight: bold;background-color: #FFFFFF;color: #000000;-webkit-appearance: none;-webkit-border-radius: 0;text-align:center;vertical-align:middle;padding-top: 2px;padding-right: 6px;padding-bottom: 3px;padding-left: 6px;cursor:pointer;} div.button:hover {background:#E1E3E7;} ");
	//out.append("div.button {border: 2px grey solid;font-family: Arial, Helvetica, sans-serif;font-size: 10pt;font-weight: bold;background-color: #FFFFFF;color: #000000;-webkit-appearance: none;-webkit-border-radius: 0;text-align:center;vertical-align:middle;padding-top: 2px;padding-right: 6px;padding-bottom: 3px;padding-left: 6px;cursor:pointer;border-radius:3px;} div.button:hover {background-color:#E1E3E7;} ");
	out.append("div.button {font-family: Arial, Helvetica, sans-serif;font-size: 10pt;font-weight: bold;background-color: #FFFFFF;color: #000000;-webkit-appearance: none;-webkit-border-radius: 0;text-align:left;vertical-align:middle;padding-top: 2px;padding-right: 6px;padding-bottom: 3px;padding-left: 6px;cursor:pointer;border-radius:3px;} div.button:hover {background-color:#E1E3E7;} ");
	out.append("hr {width:80%;}");
	out.append(".genie_header {margin-left:auto;margin-right:auto;text-align:center;font-weight:bold;font-size:1.4em;}");
	
	out.append("</style>");
	out.append("<hr>");
	
	out.append(genieGenerateDropdowns());
	
	out.append("<hr>");
	out.append(genieGenerateHardcodedWishes());
	out.append(genieGenerateSecondaryHardcodedWishes());
	out.append("<hr>");
	out.append(genieGenerateNextEffectWishes());
	return out;
}

void main(string page_text_encoded)
{
	if (form_fields()["wish"] != "")
		refresh_status(); //precautionary measure; if we submit a wish, then we might not yet have_effect() yet, so do this.
	else if (form_fields()["relay_request"] != "")
	{
		string type = form_fields()["type"];
		if (type == "shaq_fu")
			set_property("relay_genie_shaq_attack", "false");
		else if (type == "shaq_attack")
			set_property("relay_genie_shaq_attack", "true");
		return;
	}
	else
	{
		if (get_property_int("_g9Effect") == 0)
		{
			//discover g-9, we might use it!
			visit_url("desc_effect.php?whicheffect=af64d06351a3097af52def8ec6a83d9b");
		}
	}
	string page_text = page_text_encoded.choiceOverrideDecodePageText();
	string [string] form_fields = form_fields();
	//Modify page_text as you will here.
	
	if (page_text.contains_text("You have 0 wishes left today.")) //this won't happen; relay override can't detect it
	{
		write(page_text);
		return;
	}
	
	buffer genie_text = genieGenerateText();
	
	string match_text = "</td></tr></table></center></td></tr>";
	match_text = "</form>";
	page_text = page_text.replace_string(match_text, match_text + genie_text);
	
	string base_image = "https://s3.amazonaws.com/images.kingdomofloathing.com/otherimages/genie_happy.gif";
	if (get_property_boolean("relay_genie_shaq_attack"))
		base_image = "images/genie/genie_shaq.png";
	page_text = page_text.replace_string("<img src=\"https://s3.amazonaws.com/images.kingdomofloathing.com/otherimages/genie_happy.gif\">", "<div style=\"width:100px;height:200px;\"><img src=\"" + base_image + "\" id=\"genie_image\" onclick=\"genieClicked();\" style=\"width:100%;height:auto;\"></div>");
	
	write(page_text);
}
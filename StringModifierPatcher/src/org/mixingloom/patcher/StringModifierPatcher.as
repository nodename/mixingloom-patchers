/**
 * Created by IntelliJ IDEA.
 * User: James Ward <james@jamesward.org>
 * Date: 3/24/11
 * Time: 12:31 PM
 */
package org.mixingloom.patcher
{
import flash.utils.ByteArray;

import flash.utils.Endian;

import org.as3commons.bytecode.abc.AbcFile;
import org.as3commons.bytecode.abc.InstanceInfo;
import org.as3commons.bytecode.abc.LNamespace;
import org.as3commons.bytecode.abc.MethodBody;
import org.as3commons.bytecode.abc.TraitInfo;
import org.as3commons.bytecode.io.AbcDeserializer;
import org.as3commons.bytecode.io.AbcSerializer;
import org.mixingloom.SwfContext;
import org.mixingloom.SwfTag;
import org.mixingloom.invocation.InvocationType;
import org.mixingloom.utils.ByteArrayUtils;
import org.mixingloom.utils.HexDump;

public class StringModifierPatcher extends AbstractPatcher {

  public var tagName:String;
  public var originalString:String;
  public var replacementString:String;

  public function StringModifierPatcher(tagName:String, originalString:String, replacementString:String)
  {
    this.tagName = tagName;
    this.originalString = originalString;
    this.replacementString = replacementString;
  }

  override public function apply( invocationType:InvocationType, swfContext:SwfContext ):void {

    if ( invocationType.type != InvocationType.FRAME2 ) {
      invokeCallBack();

      return;
    }

    for each (var swfTag:SwfTag in swfContext.swfTags)
    {
      if ((swfTag.name == tagName) || (tagName == null))
      {
        var searchByteArray:ByteArray = new ByteArray();
        searchByteArray.writeUTFBytes(originalString);
        searchByteArray.position = 0;

        var replacementByteArray:ByteArray = new ByteArray();
        replacementByteArray.writeUTFBytes(replacementString);
        replacementByteArray.position = 0;

        swfTag.tagBody = ByteArrayUtils.findAndReplace(swfTag.tagBody, searchByteArray, replacementByteArray);

        swfTag.recordHeader = new ByteArray();
        swfTag.recordHeader.endian = Endian.LITTLE_ENDIAN;
        swfTag.recordHeader.writeByte(0xbf);
        swfTag.recordHeader.writeByte(0x14);
        swfTag.recordHeader.writeInt(swfTag.tagBody.length);

        swfTag.modified = true;
      }
    }

    invokeCallBack();
  }

}
}